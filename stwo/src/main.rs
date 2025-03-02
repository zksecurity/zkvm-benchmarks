use clap::Parser;
use utils::size;
use std::process::{Command, Stdio};
use std::io::{BufRead, BufReader};
use std::time::{Duration, Instant};
use std::io::Write;
use std::fs;
use std::env;
use std::path::Path;
use camino::Utf8Path;

use stwo_cairo_prover::stwo_prover::core::vcs::blake2_merkle::{Blake2sMerkleHasher, Blake2sMerkleChannel};
use stwo_cairo_adapter::vm_import::adapt_vm_output;
use stwo_cairo_adapter::ProverInput;
use stwo_cairo_prover::cairo_air::{
    default_prod_prover_parameters, verify_cairo,
    ProverParameters, CairoProof,
};

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
        "sha3-chain" => {
            bench_keccak_chain(cli.n)
        },
        "sha2-chain" => {
            bench_sha256_chain(cli.n)
        },
        "mat-mul" => {
            bench_mat_mul(cli.n)
        },
        _ => unreachable!()

    };
    
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();

}

fn bench_fibonacci(n: u32) -> (Duration, usize, Duration, usize) {

    let bench_dir = "fibonacci".to_string();
    
    if let Err(e) = env::set_current_dir(Path::new(&bench_dir)) {
        eprintln!("Failed to change directory: {}", e);
    } else {
        println!("Changed directory to: {}", bench_dir);
    }
    
    println!("Running Stwo Prover...");
    let prover_start = Instant::now();
    let output = Command::new("sh")
        .arg("-c")
        .arg(format!("scarb prove --execute --print-program-output --arguments {}", n))
        .stdout(Stdio::piped())
        .stderr(Stdio::piped()) 
        .output()
        .expect("Failed to execute scarb prove");
    let prover_end = Instant::now();

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

    let proof_path = format!("{target_path}/proof/proof.json");
    let priv_inp_path = format!("{target_path}/air_private_input.json");
    let pub_inp_path = format!("{target_path}/air_public_input.json");

    println!("Running Stwo Verifier...");
    let verifier_start = Instant::now();
    let _ = Command::new("sh")
        .arg("-c")
        .arg(format!("scarb verify --proof-file {}", proof_path))
        .stdout(Stdio::piped())
        .stderr(Stdio::piped()) 
        .output()
        .expect("Failed to execute scarb prove");
    let verifier_end = Instant::now();

    let proof = load_proof(&proof_path);
    let proof_size = size(&proof);

    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&pub_inp_path), Path::new(&priv_inp_path)).unwrap();
    let casm_states_by_opcode = vm_output.state_transitions.casm_states_by_opcode;
    let counts = casm_states_by_opcode.counts();
    let cycle_count = counts.iter().map(|(_, count)| count).sum::<usize>();

    println!("proof size: {:?}", proof_size);
    println!("cycle_count: {:?}", cycle_count);

    if let Err(e) = env::set_current_dir(Path::new("../")) {
        eprintln!("Failed to change directory: {}", e);
    } else {
        println!("Changed directory to: /stwo");
    }


    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}

fn bench_mat_mul(n: u32) -> (Duration, usize, Duration, usize) {

    let bench_dir = "mat_mul".to_string();
    
    if let Err(e) = env::set_current_dir(Path::new(&bench_dir)) {
        eprintln!("Failed to change directory: {}", e);
    } else {
        println!("Changed directory to: {}", bench_dir);
    }
    
    println!("Running Stwo Prover...");
    let prover_start = Instant::now();
    let output = Command::new("sh")
        .arg("-c")
        .arg(format!("scarb prove --execute --print-program-output --arguments {}", n))
        .stdout(Stdio::piped())
        .stderr(Stdio::piped()) 
        .output()
        .expect("Failed to execute scarb prove");
    let prover_end = Instant::now();

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

    let proof_path = format!("{target_path}/proof/proof.json");
    let priv_inp_path = format!("{target_path}/air_private_input.json");
    let pub_inp_path = format!("{target_path}/air_public_input.json");

    println!("Running Stwo Verifier...");
    let verifier_start = Instant::now();
    let _ = Command::new("sh")
        .arg("-c")
        .arg(format!("scarb verify --proof-file {}", proof_path))
        .stdout(Stdio::piped())
        .stderr(Stdio::piped()) 
        .output()
        .expect("Failed to execute scarb prove");
    let verifier_end = Instant::now();

    let proof = load_proof(&proof_path);
    let proof_size = size(&proof);

    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&pub_inp_path), Path::new(&priv_inp_path)).unwrap();
    let casm_states_by_opcode = vm_output.state_transitions.casm_states_by_opcode;
    let counts = casm_states_by_opcode.counts();
    let cycle_count = counts.iter().map(|(_, count)| count).sum::<usize>();

    println!("proof size: {:?}", proof_size);
    println!("cycle_count: {:?}", cycle_count);

    if let Err(e) = env::set_current_dir(Path::new("../")) {
        eprintln!("Failed to change directory: {}", e);
    } else {
        println!("Changed directory to: /stwo");
    }


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
        .arg(&program_path)
        .arg("--output")
        .arg(&output_path)
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
        // "cairo-run --program={} --layout=starknet_with_keccak --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
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
    let proof_path = format!("./sha256/proof_{}.json", n);
    let adapted_command = format!(
        "./stwo-cairo/stwo_cairo_prover/target/release/adapted_stwo --pub_json {} --priv_json {} --proof_path {} --display_components",
        public_input, private_input, proof_path
    );

    let prover_start = Instant::now();
    let _ = Command::new("sh")
        .arg("-c")
        .arg(adapted_command)
        .output()
        .expect("Failed to execute adapted_stwo command");
    let prover_end = Instant::now();

    let proof = load_proof(&proof_path);
    let proof_size = size(&proof);
    
    println!("Running Stwo Verifier...");
    let ProverParameters { pcs_config } = default_prod_prover_parameters();
    let verifier_start = Instant::now();
    verify_cairo::<Blake2sMerkleChannel>(proof, pcs_config).unwrap();
    let verifier_end = Instant::now();

    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&public_input), Path::new(&private_input)).unwrap();
    let casm_states_by_opcode = vm_output.state_transitions.casm_states_by_opcode;
    let counts = casm_states_by_opcode.counts();
    let cycle_count = counts.iter().map(|(_, count)| count).sum::<usize>();

    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}

fn bench_sha256_chain(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha256-chain/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "../stone/sha256-chain/programs/sha256_chain.cairo".to_string();
    let output_path = "./sha256-chain/sha256_chain.json".to_string();

    let public_input = "./sha256-chain/public_input.json".to_string();
    let private_input = "./sha256-chain/private_input.json".to_string();
    let trace = "./sha256-chain/trace.bin".to_string();
    let memory = "./sha256-chain/memory.bin".to_string();

    println!("Generating Prover Input Files...");
    let status = Command::new("cairo-compile")
        .arg(&program_path)
        .arg("--output")
        .arg(&output_path)
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
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
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
    let proof_path = format!("./sha256-chain/proof_{}.json", n);
    let adapted_command = format!(
        "./stwo-cairo/stwo_cairo_prover/target/release/adapted_stwo --pub_json {} --priv_json {} --proof_path {} --display_components",
        public_input, private_input, proof_path
    );

    let prover_start = Instant::now();
    let _ = Command::new("sh")
        .arg("-c")
        .arg(adapted_command)
        .output()
        .expect("Failed to execute adapted_stwo command");
    let prover_end = Instant::now();

    let proof = load_proof(&proof_path);
    let proof_size = size(&proof);
    
    println!("Running Stwo Verifier...");
    let ProverParameters { pcs_config } = default_prod_prover_parameters();
    let verifier_start = Instant::now();
    verify_cairo::<Blake2sMerkleChannel>(proof, pcs_config).unwrap();
    let verifier_end = Instant::now();

    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&public_input), Path::new(&private_input)).unwrap();
    let casm_states_by_opcode = vm_output.state_transitions.casm_states_by_opcode;
    let counts = casm_states_by_opcode.counts();
    let cycle_count = counts.iter().map(|(_, count)| count).sum::<usize>();

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
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
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
    let proof_path = format!("./keccak/proof_{}.json", n);
    let adapted_command = format!(
        "./stwo-cairo/stwo_cairo_prover/target/release/adapted_stwo --pub_json {} --priv_json {} --proof_path {} --display_components",
        public_input, private_input, proof_path
    );

    let prover_start = Instant::now();
    let _ = Command::new("sh")
        .arg("-c")
        .arg(adapted_command)
        .output()
        .expect("Failed to execute adapted_stwo command");
    let prover_end = Instant::now();

    let proof = load_proof(&proof_path);
    let proof_size = size(&proof);
    
    println!("Running Stwo Verifier...");
    let ProverParameters { pcs_config } = default_prod_prover_parameters();
    let verifier_start = Instant::now();
    verify_cairo::<Blake2sMerkleChannel>(proof, pcs_config).unwrap();
    let verifier_end = Instant::now();

    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&public_input), Path::new(&private_input)).unwrap();
    let casm_states_by_opcode = vm_output.state_transitions.casm_states_by_opcode;
    let counts = casm_states_by_opcode.counts();
    let cycle_count = counts.iter().map(|(_, count)| count).sum::<usize>();

    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}

fn bench_keccak_chain(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./keccak-chain/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "../stone/keccak-builtin-chain/programs/keccak.cairo".to_string();
    let output_path = "./keccak-chain/keccak_chain.json".to_string();

    let public_input = "./keccak-chain/public_input.json".to_string();
    let private_input = "./keccak-chain/private_input.json".to_string();
    let trace = "./keccak-chain/trace.bin".to_string();
    let memory = "./keccak-chain/memory.bin".to_string();

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
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
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
    let proof_path = format!("./keccak-chain/proof_{}.json", n);
    let adapted_command = format!(
        "./stwo-cairo/stwo_cairo_prover/target/release/adapted_stwo --pub_json {} --priv_json {} --proof_path {} --display_components",
        public_input, private_input, proof_path
    );

    let prover_start = Instant::now();
    let _ = Command::new("sh")
        .arg("-c")
        .arg(adapted_command)
        .output()
        .expect("Failed to execute adapted_stwo command");
    let prover_end = Instant::now();

    let proof = load_proof(&proof_path);
    let proof_size = size(&proof);
    
    println!("Running Stwo Verifier...");
    let ProverParameters { pcs_config } = default_prod_prover_parameters();
    let verifier_start = Instant::now();
    verify_cairo::<Blake2sMerkleChannel>(proof, pcs_config).unwrap();
    let verifier_end = Instant::now();

    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&public_input), Path::new(&private_input)).unwrap();
    let casm_states_by_opcode = vm_output.state_transitions.casm_states_by_opcode;
    let counts = casm_states_by_opcode.counts();
    let cycle_count = counts.iter().map(|(_, count)| count).sum::<usize>();

    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}

fn load_proof(path: &str) -> CairoProof<Blake2sMerkleHasher> {
    let path = Utf8Path::new(path);
    assert!(path.exists(), "Proof file does not exist at path: {path}");
    assert!(path.is_file(), "Path is not a file: {path}");

    let proof_contents =
        fs::read_to_string(path).unwrap();
    let proof = serde_json::from_str(&proof_contents).unwrap();
    proof
}
