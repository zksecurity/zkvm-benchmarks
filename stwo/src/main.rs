use clap::Parser;
use std::process::Command;
use std::io::Write;
use std::fs;

use stwo_cairo_prover::stwo_prover::core::vcs::blake2_merkle::Blake2sMerkleChannel;
use stwo_cairo_adapter::vm_import::adapt_vm_output;
use stwo_cairo_adapter::ProverInput;
use stwo_cairo_prover::prover::{
    default_prod_prover_parameters, prove_cairo, ProverParameters,
};
use cairo_air::verifier::verify_cairo;

use std::path::Path;
use std::time::{Duration, Instant};
use utils::size;


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
            bench_sha2(cli.n)
        },
        "sha3" => {
            bench_sha3(cli.n)
        },
        "sha3-chain" => {
            bench_sha3_chain(cli.n)
        },
        "sha2-chain" => {
            bench_sha2_chain(cli.n)
        },
        "mat-mul" => {
            bench_mat_mul(cli.n)
        },
        "ec" => {
            bench_ec(cli.n)
        },
        _ => unreachable!()

    };
    
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();

}

fn bench_fibonacci(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./fib/input.json".to_string();
    fs::write(&program_input, input).expect("Failed to write input file");

    let program_path = "../fib/fibonacci.cairo".to_string();
    let output_path = "./fib/fib.json".to_string();

    let public_input = "./fib/public_input.json".to_string();
    let private_input = "./fib/private_input.json".to_string();
    let trace = "./fib/trace.bin".to_string();
    let memory = "./fib/memory.bin".to_string();

    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory)
}

fn bench_mat_mul(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./mat_mul/input.json".to_string();
    fs::write(&program_input, input).expect("Failed to write input file");

    let program_path = "./mat_mul/mat_mul.cairo".to_string();
    let output_path = "./mat_mul/mat_mul.json".to_string();

    let public_input = "./mat_mul/public_input.json".to_string();
    let private_input = "./mat_mul/private_input.json".to_string();
    let trace = "./mat_mul/trace.bin".to_string();
    let memory = "./mat_mul/memory.bin".to_string();

    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory)
}

fn bench_sha2(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha2/input.json".to_string();
    fs::write(&program_input, input).expect("Failed to write input file");

    let program_path = "./sha2/sha256.cairo".to_string();
    let output_path = "./sha2/sha2.json".to_string();

    let public_input = "./sha2/public_input.json".to_string();
    let private_input = "./sha2/private_input.json".to_string();
    let trace = "./sha2/trace.bin".to_string();
    let memory = "./sha2/memory.bin".to_string();

    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory)
}

fn bench_sha2_chain(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha2-chain/input.json".to_string();
    fs::write(&program_input, input).expect("Failed to write input file");

    let program_path = "./sha2-chain/sha256_chain.cairo".to_string();
    let output_path = "./sha2-chain/sha2_chain.json".to_string();

    let public_input = "./sha2-chain/public_input.json".to_string();
    let private_input = "./sha2-chain/private_input.json".to_string();
    let trace = "./sha2-chain/trace.bin".to_string();
    let memory = "./sha2-chain/memory.bin".to_string();

    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory)
}


fn bench_sha3(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha3/input.json".to_string();
    fs::write(&program_input, input).expect("Failed to write input file");

    let program_path = "./sha3/cairo_keccak.cairo".to_string();
    let output_path = "./sha3/sha3.json".to_string();

    let public_input = "./sha3/public_input.json".to_string();
    let private_input = "./sha3/private_input.json".to_string();
    let trace = "./sha3/trace.bin".to_string();
    let memory = "./sha3/memory.bin".to_string();

    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory)
}

fn bench_sha3_chain(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha3-chain/input.json".to_string();
    fs::write(&program_input, input).expect("Failed to write input file");

    let program_path = "./sha3-chain/keccak_chain.cairo".to_string();
    let output_path = "./sha3-chain/sha3_chain.json".to_string();

    let public_input = "./sha3-chain/public_input.json".to_string();
    let private_input = "./sha3-chain/private_input.json".to_string();
    let trace = "./sha3-chain/trace.bin".to_string();
    let memory = "./sha3-chain/memory.bin".to_string();

    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory)
}

fn bench_ec(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./ec/input.json".to_string();
    fs::write(&program_input, input).expect("Failed to write input file");

    let program_path = "./ec/ec_add.cairo".to_string();
    let output_path = "./ec/ec.json".to_string();

    let public_input = "./ec/public_input.json".to_string();
    let private_input = "./ec/private_input.json".to_string();
    let trace = "./ec/trace.bin".to_string();
    let memory = "./ec/memory.bin".to_string();

    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory)
}

pub fn prove_and_verify(
    program_input: String,
    program_path: String, 
    output_path: String, 
    public_input: String, 
    private_input: String, 
    trace: String, 
    memory: String
) -> (Duration, usize, Duration, usize) {
    
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
        "cairo-run --program={} --cairo_layout_params_file=cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        output_path, program_input, public_input, private_input, trace, memory,
    );
    println!("cairo-run: {:?}", run_command);
    let output = Command::new("sh")
        .arg("-c")
        .arg(run_command)
        .output();
    match output {
        Ok(output) if output.status.success() => {
            println!("cairo-run successful!");
            println!("stdout: {}", String::from_utf8_lossy(&output.stdout));
        }
        Ok(output) => {
            eprintln!(
                "cairo-run failed with exit code: {}",
                output.status.code().unwrap_or(-1)
            );
            eprintln!("stderr: {}", String::from_utf8_lossy(&output.stderr));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-run: {}", err);
        }
    }

    println!("Running Stwo Prover...");
    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&public_input), Path::new(&private_input)).unwrap();
    let ProverParameters { pcs_config, preprocessed_trace, .. } = default_prod_prover_parameters();
    let prover_start = Instant::now();
    let proof = prove_cairo::<Blake2sMerkleChannel>(vm_output, pcs_config, preprocessed_trace).unwrap();
    let prover_end = Instant::now();
    println!("Proof Generated Successfully...");

    let proof_size = size(&proof);
    
    println!("Running Stwo Verifier...");
    let verifier_start = Instant::now();
    verify_cairo::<Blake2sMerkleChannel>(proof, pcs_config, preprocessed_trace).unwrap();
    let verifier_end = Instant::now();
    println!("Proof Verified Successfully...");

    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&public_input), Path::new(&private_input)).unwrap();
    let counts = &vm_output.state_transitions.casm_states_by_opcode.counts();
    let cycle_count = counts.iter().map(|(_, count)| count).sum::<usize>();

    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}
