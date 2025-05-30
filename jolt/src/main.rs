use std::{io::Write, time::{Duration, Instant}, usize};

use jolt::Serializable;

use clap::Parser;

#[derive(Parser, Debug)]
#[clap()]
pub struct Cli {
    #[arg(long)]
    pub n: u32,
    
    #[arg(long)]
    pub program: String,
}

fn main() {
    let cli = Cli::parse();

    let (duration, proof_size, verifier_duration, cycle_count) = match cli.program.as_str() {
        "fib" => {
            benchmark_fib(cli.n)
        },
        "sha2" => {
            benchmark_sha2(cli.n as usize)
        },
        "sha2-chain" => {
            benchmark_sha2_chain(cli.n)
        },
        "sha3" => {
            benchmark_sha3(cli.n as usize)
        },
        "sha3-chain" => {
            benchmark_sha3_chain(cli.n)
        },
        "mat-mul" => {
            benchmark_mat_mul(cli.n as usize)
        },
        "ec" => {
            benchmark_ecadd(cli.n)
        },
        _ => unreachable!()

    };
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();
}

fn benchmark_sha2_chain(iters: u32) -> (Duration, usize, Duration, usize) {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = sha2_chain_guest::compile_sha2_chain(target_dir);

    let prover_preprocessing = sha2_chain_guest::preprocess_prover_sha2_chain(&program);
    let verifier_preprocessing = sha2_chain_guest::preprocess_verifier_sha2_chain(&program);
    
    let prove_sha2_chain = sha2_chain_guest::build_prover_sha2_chain(program, prover_preprocessing);
    let verify_sha2_chain = sha2_chain_guest::build_verifier_sha2_chain(verifier_preprocessing);
    
    let input = [5u8; 32];

    let start = Instant::now();
    let (output, proof) = prove_sha2_chain(input, iters);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_sha2_chain(input, iters, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();


    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_sha3_chain(iters: u32) -> (Duration, usize, Duration, usize) {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = sha3_chain_guest::compile_sha3_chain(target_dir);

    let prover_preprocessing = sha3_chain_guest::preprocess_prover_sha3_chain(&program);
    let verifier_preprocessing = sha3_chain_guest::preprocess_verifier_sha3_chain(&program);

    let prove_sha3_chain = sha3_chain_guest::build_prover_sha3_chain(program, prover_preprocessing);
    let verify_sha3_chain = sha3_chain_guest::build_verifier_sha3_chain(verifier_preprocessing);

    let input = [5u8; 32];

    let start = Instant::now();
    let (output, proof) = prove_sha3_chain(input, iters);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_sha3_chain(input, iters, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_sha3(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = sha3_guest::compile_sha3(target_dir);

    let prover_preprocessing = sha3_guest::preprocess_prover_sha3(&program);
    let verifier_preprocessing = sha3_guest::preprocess_verifier_sha3(&program);

    let prove_sha3 = sha3_guest::build_prover_sha3(program, prover_preprocessing);
    let verify_sha3 = sha3_guest::build_verifier_sha3(verifier_preprocessing);

    let input = vec![5u8; num_bytes];
    let input = input.as_slice();

    let start = Instant::now();
    let (output, proof) = prove_sha3(input);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_sha3(input, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_sha2(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = sha2_guest::compile_sha2(target_dir);

    let prover_preprocessing = sha2_guest::preprocess_prover_sha2(&program);
    let verifier_preprocessing = sha2_guest::preprocess_verifier_sha2(&program);

    let prove_sha2 = sha2_guest::build_prover_sha2(program, prover_preprocessing);
    let verify_sha2 = sha2_guest::build_verifier_sha2(verifier_preprocessing);

    let input = vec![5u8; num_bytes];
    let input = input.as_slice();

    let start = Instant::now();
    let (output, proof) = prove_sha2(input);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_sha2(input, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_fib(n: u32) -> (Duration, usize, Duration, usize) {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = fibonacci_guest::compile_fib(target_dir);

    let prover_preprocessing = fibonacci_guest::preprocess_prover_fib(&program);
    let verifier_preprocessing = fibonacci_guest::preprocess_verifier_fib(&program);

    let prove_fib = fibonacci_guest::build_prover_fib(program, prover_preprocessing);
    let verify_fib = fibonacci_guest::build_verifier_fib(verifier_preprocessing);

    let start = Instant::now();
    let (output, proof) = prove_fib(n);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_fib(n, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_ecadd(n: u32) -> (Duration, usize, Duration, usize) {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = ec_guest::compile_ecadd(target_dir);

    let prover_preprocessing = ec_guest::preprocess_prover_ecadd(&program);
    let verifier_preprocessing = ec_guest::preprocess_verifier_ecadd(&program);

    let prove_ec = ec_guest::build_prover_ecadd(program, prover_preprocessing);
    let verify_ec = ec_guest::build_verifier_ecadd(verifier_preprocessing);

    let start = Instant::now();
    let (output, proof) = prove_ec(n);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_ec(n, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_mat_mul(size: usize) -> (Duration, usize, Duration, usize) {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = mat_mul_guest::compile_matrix_mul(target_dir);

    let prover_preprocessing = mat_mul_guest::preprocess_prover_matrix_mul(&program);
    let verifier_preprocessing = mat_mul_guest::preprocess_verifier_matrix_mul(&program);

    let prove_mat_mul = mat_mul_guest::build_prover_matrix_mul(program, prover_preprocessing);
    let verify_mat_mul = mat_mul_guest::build_verifier_matrix_mul(verifier_preprocessing);

    let start = Instant::now();
    let (output, proof) = prove_mat_mul(size);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_mat_mul(size, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}