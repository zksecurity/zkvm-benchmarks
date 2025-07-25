use clap::Parser;
use std::io::Write;
use std::fs;
use std::time::Duration;

pub mod util;
use util::prove_and_verify;


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

    let program_path = "./fib/fibonacci.cairo".to_string();
    let output_path = "./fib/fib.json".to_string();

    let public_input = "./fib/public_input.json".to_string();
    let private_input = "./fib/private_input.json".to_string();
    let trace = "./fib/trace.bin".to_string();
    let memory = "./fib/memory.bin".to_string();

    let out_dir = "./fib".to_string();
    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory, out_dir)
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

    let out_dir = "./mat_mul".to_string();
    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory, out_dir)
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

    let out_dir = "./sha2".to_string();
    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory, out_dir)
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

    let out_dir = "./sha2-chain".to_string();
    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory, out_dir)
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

    let out_dir = "./sha3".to_string();
    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory, out_dir)
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

    let out_dir = "./sha3-chain".to_string();
    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory, out_dir)
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

    let out_dir = "./ec".to_string();
    prove_and_verify(program_input, program_path, output_path, public_input, private_input, trace, memory, out_dir)
}
