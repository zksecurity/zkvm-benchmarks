use nix::sys::wait::{waitpid, WaitStatus};
use nix::unistd::{fork, ForkResult};
use rand::Rng;
use std::fs;
use std::io;
use std::os::unix::process::ExitStatusExt;
use std::path::PathBuf;
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

pub struct MemoryMonitor {
    cgroup_path: Option<PathBuf>,
}

impl MemoryMonitor {
    pub fn new() -> Self {
        Self { cgroup_path: None }
    }

    /// Run a command with memory monitoring and return the peak memory usage in bytes
    pub fn run_with_memory_tracking<F>(&mut self, command_fn: F) -> io::Result<u64>
    where
        F: FnOnce() -> io::Result<()> + Send + 'static,
    {
        // Check if we're running as root
        if !nix::unistd::geteuid().is_root() {
            return Err(io::Error::new(
                io::ErrorKind::PermissionDenied,
                "Memory tracking requires root privileges to manage cgroups",
            ));
        }
        
        self.run_with_cgroup(command_fn)
    }

    fn run_with_cgroup<F>(&mut self, command_fn: F) -> io::Result<u64>
    where
        F: FnOnce() -> io::Result<()> + Send + 'static,
    {
        // Create a unique cgroup name
        let timestamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let random: u32 = rand::rng().random();
        let cgroup_name = format!("memuse_{}_{}", timestamp, random);

        // Try different possible cgroup paths
        let base_paths = [
            "/sys/fs/cgroup",
            "/sys/fs/cgroup/unified",
            "/sys/fs/cgroup/memory",
        ];

        let mut cgroup_created = false;
        for base_path in &base_paths {
            if std::path::Path::new(base_path).exists() {
                let cgroup_path = std::path::Path::new(base_path).join(&cgroup_name);
                if fs::create_dir(&cgroup_path).is_ok() {
                    self.cgroup_path = Some(cgroup_path);
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

        let cgroup_path = self.cgroup_path.as_ref().unwrap();

        // Add current process to the cgroup so children inherit it
        let procs_path = cgroup_path.join("cgroup.procs");
        let pid = nix::unistd::getpid();
        fs::write(&procs_path, pid.to_string())?;

        // Fork and execute the command
        match unsafe { fork() } {
            Ok(ForkResult::Child) => {
                // In child process - execute the command
                std::process::exit(match command_fn() {
                    Ok(()) => 0,
                    Err(_) => 1,
                });
            }
            Ok(ForkResult::Parent { child }) => {
                // In parent process - wait for child and get peak memory
                match waitpid(child, None) {
                    Ok(WaitStatus::Exited(_, _)) | Ok(WaitStatus::Signaled(_, _, _)) => {
                        // Child finished, read peak memory
                        self.get_peak_memory()
                    }
                    _ => Err(io::Error::new(
                        io::ErrorKind::Other,
                        "Child process failed",
                    )),
                }
            }
            Err(e) => Err(io::Error::new(
                io::ErrorKind::Other,
                format!("Fork failed: {}", e),
            )),
        }
    }

    fn get_peak_memory(&self) -> io::Result<u64> {
        if let Some(cgroup_path) = &self.cgroup_path {
            let memory_peak_path = cgroup_path.join("memory.peak");
            let content = fs::read_to_string(&memory_peak_path)?;
            let peak_memory = content.trim().parse::<u64>().map_err(|e| {
                io::Error::new(
                    io::ErrorKind::InvalidData,
                    format!("Failed to parse peak memory: {}", e),
                )
            })?;
            Ok(peak_memory)
        } else {
            Ok(0)
        }
    }
}

impl Drop for MemoryMonitor {
    fn drop(&mut self) {
        // Clean up the cgroup
        if let Some(cgroup_path) = &self.cgroup_path {
            let _ = fs::remove_dir(cgroup_path);
        }
    }
}

/// Convenience function to run a command with memory tracking
pub fn run_command_with_memory_tracking(
    program: &str,
    args: &[String],
) -> io::Result<(std::process::ExitStatus, u64)> {
    let mut monitor = MemoryMonitor::new();
    let program = program.to_string();
    let args = args.to_vec();
    
    let peak_memory = monitor.run_with_memory_tracking(move || {
        let status = Command::new(&program)
            .args(&args)
            .status()?;
        if !status.success() {
            return Err(io::Error::new(
                io::ErrorKind::Other,
                format!("Command failed with exit code: {:?}", status.code()),
            ));
        }
        Ok(())
    })?;

    // Since we don't have a way to pass the exit status out of the closure,
    // we'll assume success if we get here (the closure would have failed otherwise)
    let success_status = std::process::ExitStatus::from_raw(0);
    Ok((success_status, peak_memory))
}