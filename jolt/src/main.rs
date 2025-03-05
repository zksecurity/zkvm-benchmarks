use std::{io::Write, time::{Duration, Instant}, usize};

use jolt::Serializable;

use clap::Parser;

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
    // read args from cli
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
            benchmark_mat_mul(cli.n)
        },
        "binary-search" => {
            benchmark_binary_search(cli.n as u8)
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
    let (prove_sha2_chain, verify_sha2_chain) = sha2_chain_guest::build_sha2_chain();
    let input = [5u8; 32];

    let start = Instant::now();
    let (_output, proof) = prove_sha2_chain(input, iters);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_sha2_chain(proof);
    let verify_end = Instant::now();
    assert!(is_valid);

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_sha3_chain(iters: u32) -> (Duration, usize, Duration, usize) {
    let (prove_sha3_chain, verify_sha3_chain) = sha3_chain_guest::build_sha3_chain();
    let input = [5u8; 32];

    let start = Instant::now();
    let (_output, proof) = prove_sha3_chain(input, iters);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_sha3_chain(proof);
    let verify_end = Instant::now();
    assert!(is_valid);

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_sha2(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let (prove_sha2, verify_sha2) = sha2_guest::build_sha2();

    let input = vec![5u8; num_bytes];
    let input = input.as_slice();

    let start = Instant::now();
    let (_output, proof) = prove_sha2(input);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_sha2(proof);
    let verify_end = Instant::now();
    assert!(is_valid);

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_sha3(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let (prove_sha3, verify_sha3) = sha3_guest::build_sha3();

    let input = vec![5u8; num_bytes];
    let input = input.as_slice();

    let start = Instant::now();
    let (_output, proof) = prove_sha3(input);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_sha3(proof);
    let verify_end = Instant::now();
    assert!(is_valid);

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_fib(n: u32) -> (Duration, usize, Duration, usize) {
    let (prove_fib, verify_fib) = fibonacci_guest::build_fib();

    let start = Instant::now();
    let (_output, proof) = prove_fib(n);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_fib(proof);
    let verify_end = Instant::now();
    assert!(is_valid);

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_ecadd(n: u32) -> (Duration, usize, Duration, usize) {
    let (prove_ecadd, verify_ecadd) = ec_guest::build_ecadd();
    
    let start = Instant::now();
    let (_output, proof) = prove_ecadd(n);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_ecadd(proof);
    let verify_end = Instant::now();
    assert!(is_valid);

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_binary_search(n: u8) -> (Duration, usize, Duration, usize) {
    let (prove_bs, verify_bs) = binary_search_guest::build_find();

    let input: Vec<u8> = (1..=n).collect();

    let start = Instant::now();
    let (_output, proof) = prove_bs(&input);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let verify_start = Instant::now();
    let is_valid = verify_bs(proof);
    let verify_end = Instant::now();
    assert!(is_valid);

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
}

fn benchmark_mat_mul(size: u32) -> (Duration, usize, Duration, usize) {
    // let (prove_mat_mul, verify_mat_mul) = mat_mul_guest::build_matrix_mul();
    
    // let start = Instant::now();
    // let (_output, proof) = prove_mat_mul(size as usize);
    // let end = Instant::now();

    // let proof_size = proof.size().unwrap();
    // let trace_len = proof.proof.trace_length;

    // let verify_start = Instant::now();
    // let is_valid = verify_mat_mul(proof);
    // let verify_end = Instant::now();
    // assert!(is_valid);
        
    // (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)

    let (duration, proof_size, verifier_duration, cycle_count) = match size {
        10 => {
            let (prove_mat_mul, verify_mat_mul) = mat_mul_guest::build_matrix_mul_10();
            let start = Instant::now();
            let (_output, proof) = prove_mat_mul();
            let end = Instant::now();

            let proof_size = proof.size().unwrap();
            let trace_len = proof.proof.trace_length;
        
            let verify_start = Instant::now();
            let is_valid = verify_mat_mul(proof);
            let verify_end = Instant::now();
            assert!(is_valid);
        
            (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
        },
        20 => {
            let (prove_mat_mul, verify_mat_mul) = mat_mul_guest::build_matrix_mul_20();
            let start = Instant::now();
            let (_output, proof) = prove_mat_mul();
            let end = Instant::now();

            let proof_size = proof.size().unwrap();
            let trace_len = proof.proof.trace_length;
        
            let verify_start = Instant::now();
            let is_valid = verify_mat_mul(proof);
            let verify_end = Instant::now();
            assert!(is_valid);
        
            (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
        },
        40 => {
            let (prove_mat_mul, verify_mat_mul) = mat_mul_guest::build_matrix_mul_40();
            let start = Instant::now();
            let (_output, proof) = prove_mat_mul();
            let end = Instant::now();

            let proof_size = proof.size().unwrap();
            let trace_len = proof.proof.trace_length;
        
            let verify_start = Instant::now();
            let is_valid = verify_mat_mul(proof);
            let verify_end = Instant::now();
            assert!(is_valid);
        
            (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
        },
        60 => {
            let (prove_mat_mul, verify_mat_mul) = mat_mul_guest::build_matrix_mul_60();
            let start = Instant::now();
            let (_output, proof) = prove_mat_mul();
            let end = Instant::now();

            let proof_size = proof.size().unwrap();
            let trace_len = proof.proof.trace_length;
        
            let verify_start = Instant::now();
            let is_valid = verify_mat_mul(proof);
            let verify_end = Instant::now();
            assert!(is_valid);
        
            (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), trace_len)
        },
        _ => unreachable!()
    };
    
    (duration, proof_size, verifier_duration, cycle_count) 
}