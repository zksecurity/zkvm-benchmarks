use std::path::PathBuf;
use std::sync::Mutex;
use std::time::{SystemTime, UNIX_EPOCH};
use std::{fs, io};

use nix::sys::wait::{waitpid, WaitStatus};
use nix::unistd::{fork, ForkResult, Pid};
use rand::Rng;

static MEMORY_TRACKING_LOCK: Mutex<()> = Mutex::new(());

// special exit code used to detect
// failure in the child before execv
const EXEC_FAILURE_EXIT_CODE: i32 = 123;

#[derive(serde::Serialize, serde::Deserialize, Clone, Copy, Debug)]
#[serde(rename_all = "lowercase")]
pub enum MemoryResult {
    Exited(i32),
    Signal(i32),
}

impl MemoryResult {
    pub fn is_ok(self) -> bool {
        match self {
            MemoryResult::Exited(code) => code == 0,
            MemoryResult::Signal(_) => false,
        }
    }
}

#[derive(serde::Serialize, serde::Deserialize)]
pub struct MemoryUsage {
    pub memory: u64,
    pub result: MemoryResult,
}

/// Run a command with memory monitoring and
/// return the peak memory usage in bytes and exit status
pub fn run_with_memory_tracking(program: &str, args: &[String]) -> io::Result<MemoryUsage> {
    // Check if we're running as root
    if !nix::unistd::geteuid().is_root() {
        return Err(io::Error::new(
            io::ErrorKind::PermissionDenied,
            "Memory tracking requires root privileges to manage cgroups",
        ));
    }

    // Take the global lock to ensure only one memory tracking operation at a time
    let _lock = MEMORY_TRACKING_LOCK.lock().unwrap();

    // Create a unique cgroup name
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    let random: u64 = rand::rng().random();
    let cgroup_name = format!("memuse_{}_{}", timestamp, random);

    // Try different possible cgroup paths
    let base_paths = [
        "/sys/fs/cgroup",
        "/sys/fs/cgroup/unified",
        "/sys/fs/cgroup/memory",
    ];

    let mut cgroup_path: PathBuf = PathBuf::new();
    let mut cgroup_created = false;
    for base_path in &base_paths {
        if std::path::Path::new(base_path).exists() {
            cgroup_path = std::path::Path::new(base_path).join(&cgroup_name);
            if fs::create_dir(&cgroup_path).is_ok() {
                cgroup_created = true;
                break;
            }
        }
    }

    if !cgroup_created {
        return Err(io::Error::new(
            io::ErrorKind::Other,
            "Failed to create cgroup",
        ));
    }

    fn get_peak_memory(cgroup_path: &PathBuf) -> Result<u64, io::Error> {
        let memory_peak_path = cgroup_path.join("memory.peak");
        let content = fs::read_to_string(&memory_peak_path)?;
        let peak_memory = content.trim().parse::<u64>().map_err(|e| {
            io::Error::new(
                io::ErrorKind::InvalidData,
                format!("Failed to parse peak memory: {}", e),
            )
        })?;
        Ok(peak_memory)
    }

    // Add current process to the cgroup so children inherit it
    let procs_path = cgroup_path.join("cgroup.procs");
    let pid: Pid = nix::unistd::getpid();
    fs::write(&procs_path, pid.to_string())?;

    // record memory usage before executing the child
    // this assumes that memory usage of *THIS* program
    // remains constant between starting the child and making the measurement
    let mem_usage_before = get_peak_memory(&cgroup_path)?;

    // Fork and execute the command
    let result = match unsafe { fork() } {
        Ok(ForkResult::Child) => {
            // In child process - become the program using exec
            let program_cstring = match std::ffi::CString::new(program) {
                Ok(s) => s,
                Err(_) => std::process::exit(EXEC_FAILURE_EXIT_CODE),
            };
            let mut args_cstring: Vec<std::ffi::CString> = vec![program_cstring.clone()];
            for arg in args {
                match std::ffi::CString::new(arg.as_str()) {
                    Ok(s) => args_cstring.push(s),
                    Err(_) => std::process::exit(EXEC_FAILURE_EXIT_CODE),
                }
            }
            match nix::unistd::execv(&program_cstring, &args_cstring) {
                Err(_e) => std::process::exit(EXEC_FAILURE_EXIT_CODE),
                Ok(_) => unreachable!(), // execv never returns on success
            }
        }
        Ok(ForkResult::Parent { child }) => {
            // In parent process - wait for child and get peak memory
            match waitpid(child, None) {
                Ok(WaitStatus::Exited(_, status)) => {
                    if status == EXEC_FAILURE_EXIT_CODE {
                        Err(io::Error::new(
                            io::ErrorKind::Other,
                            format!("Failed to execute program: {}", program),
                        ))
                    } else {
                        Ok(MemoryResult::Exited(status))
                    }
                }
                Ok(WaitStatus::Signaled(_, signal, _core_dump)) => {
                    Ok(MemoryResult::Signal(signal as i32))
                }
                _ => Err(io::Error::new(io::ErrorKind::Other, "Child process failed")),
            }
        }
        Err(e) => Err(io::Error::new(
            io::ErrorKind::Other,
            format!("Fork failed: {}", e),
        )),
    }?;

    // Child finished, read peak memory
    let peak_memory_after = get_peak_memory(&cgroup_path)?;

    // Remove the cgroup
    let _ = fs::remove_dir(&cgroup_path);

    //
    Ok(MemoryUsage {
        memory: peak_memory_after.saturating_sub(mem_usage_before),
        result,
    })
}
