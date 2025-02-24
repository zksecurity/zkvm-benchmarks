use clap::Parser;
use std::process::{Command, Stdio};
use std::io::{BufRead, BufReader};
use std::time::{Duration, Instant};
use std::io::Write;
use std::fs;

/// A tool to build and optionally benchmark a cargo project
#[derive(Parser, Debug)]
#[clap()]
pub struct Cli {
    #[arg(long)]
    pub n: u32,
    
    /// Run the benchmark under heaptrack for memory profiling
    #[arg(long)]
    pub program: String,
}


fn main() {

    let cli = Cli::parse();

    let (duration, proof_size, verifier_duration, cycle_count) = match cli.program.as_str() {
        "fib" => {
            bench_fibonacci(cli.n)
        },
        "sha2" => {
            bench_sha256(cli.n)
        },
        "sha3" => {
            bench_keccak(cli.n)
        },
        _ => unreachable!()

    };
    
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();

}

fn bench_fibonacci(n: u32) -> (Duration, usize, Duration, usize) {

    println!("Running the `scarb execute` command...");
    let output = Command::new("sh")
        .arg("-c")
        .arg(format!("cd fibonacci && scarb execute -p fibonacci --print-program-output --arguments {}", n))
        .stdout(Stdio::piped())  // Capture stdout
        .stderr(Stdio::piped())  // Capture stderr
        .output()  // Wait for the command to complete and get the output
        .expect("Failed to execute scarb command");

    let stdout = String::from_utf8_lossy(&output.stdout);
    let reader = BufReader::new(stdout.as_bytes());
    
    // Parse the output to find the target path
    let mut target_path = String::new();
    for line in reader.lines() {
        let line = line.expect("Failed to read line");
        if line.contains("Saving output to:") {
            target_path = line.split(':').nth(1).unwrap_or("").trim().to_string();
            break;
        }
    }    

    // Ensure the target path was found
    if target_path.is_empty() {
        eprintln!("Failed to find target path in output.");
        return (Duration::new(0, 0), 0, Duration::new(0, 0), 0);
    }

    println!("Running Stwo Prover...");
    let adapted_command = format!(
        "./stwo-cairo/stwo_cairo_prover/target/release/adapted_stwo --pub_json ./fibonacci/{}/air_public_input.json --priv_json ./fibonacci/{}/air_private_input.json --proof_path ./fibonacci/fib_{}_proof.json --display_components",
        target_path, target_path, n
    );

    let prover_start = Instant::now();
    let _ = Command::new("sh")
        .arg("-c")
        .arg(adapted_command)
        .output()  // Execute and wait for the command to complete
        .expect("Failed to execute adapted_stwo command");
    let prover_end = Instant::now();

    let verifier_start = Instant::now();
    // ADD Verifier Code
    let verifier_end = Instant::now();

    let proof_size = 0;  // Placeholder for proof size
    let cycle_count = 0;  // Placeholder for cycle count

    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}

fn bench_sha256(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha256/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "../stone/sha256/programs/sha256.cairo".to_string();
    let output_path = "./sha256/sha256.json".to_string();

    let public_input = "./sha256/public_input.json".to_string();
    let private_input = "./sha256/private_input.json".to_string();
    let trace = "./sha256/trace.bin".to_string();
    let memory = "./sha256/memory.bin".to_string();

    println!("Generating Prover Input Files...");
    let status = Command::new("cairo-compile")
        .arg(&program_path) // Path to the Cairo program
        .arg("--output")
        .arg(&output_path) // Output file path
        .arg("--proof_mode")
        .status();

    match status {
        Ok(status) if status.success() => {
            println!("Compilation successful! Compiled file saved to: {}", output_path);
        }
        Ok(status) => {
            eprintln!("Compilation failed with exit code: {}", status.code().unwrap_or(-1));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-compile: {}", err);
        }
    }

    let run_command = format!(
        "cairo-run --program={} --layout=starknet_with_keccak --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        output_path, program_input, public_input, private_input, trace, memory,
    );
    let output = Command::new("sh")
        .arg("-c")
        .arg(run_command)
        .output().unwrap();
    if !output.status.success() {
        eprintln!(
            "Error running cairo-run: {}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    println!("Running Stwo Prover...");
    let adapted_command = format!(
        "./stwo-cairo/stwo_cairo_prover/target/release/adapted_stwo --pub_json {} --priv_json {} --proof_path ./sha256/proof_{}.json --display_components",
        public_input, private_input, n
    );

    let prover_start = Instant::now();
    let _ = Command::new("sh")
        .arg("-c")
        .arg(adapted_command)
        .output()  // Execute and wait for the command to complete
        .expect("Failed to execute adapted_stwo command");
    let prover_end = Instant::now();

    let verifier_start = Instant::now();
    // ADD Verifier Code
    let verifier_end = Instant::now();

    let proof_size = 0;  // Placeholder for proof size
    let cycle_count = 0;  // Placeholder for cycle count

    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}


fn bench_keccak(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./keccak/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "../stone/keccak/programs/cairo_keccak.cairo".to_string();
    let output_path = "./keccak/keccak.json".to_string();

    let public_input = "./keccak/public_input.json".to_string();
    let private_input = "./keccak/private_input.json".to_string();
    let trace = "./keccak/trace.bin".to_string();
    let memory = "./keccak/memory.bin".to_string();

    println!("Generating Prover Input Files...");
    let status = Command::new("cairo-compile")
        .arg(&program_path) // Path to the Cairo program
        .arg("--output")
        .arg(&output_path) // Output file path
        .arg("--proof_mode")
        .status();

    match status {
        Ok(status) if status.success() => {
            println!("Compilation successful! Compiled file saved to: {}", output_path);
        }
        Ok(status) => {
            eprintln!("Compilation failed with exit code: {}", status.code().unwrap_or(-1));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-compile: {}", err);
        }
    }

    let run_command = format!(
        "cairo-run --program={} --layout=starknet_with_keccak --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        output_path, program_input, public_input, private_input, trace, memory,
    );
    let output = Command::new("sh")
        .arg("-c")
        .arg(run_command)
        .output().unwrap();
    if !output.status.success() {
        eprintln!(
            "Error running cairo-run: {}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    println!("Running Stwo Prover...");
    let adapted_command = format!(
        "./stwo-cairo/stwo_cairo_prover/target/release/adapted_stwo --pub_json {} --priv_json {} --proof_path ./keccak/proof_{}.json --display_components",
        public_input, private_input, n
    );

    let prover_start = Instant::now();
    let _ = Command::new("sh")
        .arg("-c")
        .arg(adapted_command)
        .output()  // Execute and wait for the command to complete
        .expect("Failed to execute adapted_stwo command");
    let prover_end = Instant::now();

    let verifier_start = Instant::now();
    // ADD Verifier Code
    let verifier_end = Instant::now();

    let proof_size = 0;  // Placeholder for proof size
    let cycle_count = 0;  // Placeholder for cycle count

    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}
