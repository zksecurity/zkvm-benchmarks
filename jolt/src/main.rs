use std::{io::Write, time::{Duration, Instant}, usize};

use jolt::Serializable;

use clap::{Parser};

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

    let (duration, proof_size) = match cli.program.as_str() {
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
        "binary-search" => {
            benchmark_binary_search(cli.n as usize)
        },
        _ => unreachable!()

    };
    println!("duration: {:?}", duration);
    println!("proof size: {:?}", proof_size);


    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}}}", proof_size, duration.as_millis()).as_bytes()).unwrap();

}

fn benchmark_sha2_chain(iters: u32) -> (Duration, usize) {
    let (prove_sha2_chain, _verify_sha2_chain) = sha2_chain_guest::build_sha2_chain();
    let input = [5u8; 32];

    let start = Instant::now();
    let (_output, proof) = prove_sha2_chain(input, iters);
    let end = Instant::now();

    (end.duration_since(start), proof.size().unwrap())
}

fn benchmark_sha3_chain(iters: u32) -> (Duration, usize) {
    let (prove_sha3_chain, _verify_sha3_chain) = sha3_chain_guest::build_sha3_chain();
    let input = [5u8; 32];

    let start = Instant::now();
    let (_output, proof) = prove_sha3_chain(input, iters);
    let end = Instant::now();

    (end.duration_since(start), proof.size().unwrap())
}

fn benchmark_sha2(num_bytes: usize) -> (Duration, usize) {
    let (prove_sha2, _verify_sha2) = sha2_guest::build_sha2();

    let input = vec![5u8; num_bytes];
    let input = input.as_slice();

    let start = Instant::now();
    let (_output, proof) = prove_sha2(input);
    let end = Instant::now();

    (end.duration_since(start), proof.size().unwrap())
}

fn benchmark_sha3(num_bytes: usize) -> (Duration, usize) {
    let (prove_sha3, _verify_sha3) = sha3_guest::build_sha3();

    let input = vec![5u8; num_bytes];
    let input = input.as_slice();

    let start = Instant::now();
    let (_output, proof) = prove_sha3(input);
    let end = Instant::now();

    (end.duration_since(start), proof.size().unwrap())
}

fn benchmark_fib(n: u32) -> (Duration, usize) {
    let (prove_fib, _verify_fib) = fibonacci_guest::build_fib();

    let start = Instant::now();
    let (_output, proof) = prove_fib(n);
    let end = Instant::now();

    (end.duration_since(start), proof.size().unwrap())
}

// fn benchmark_bigmem(value: u32) -> (Duration, usize) {
//     let (prove_bigmem, verify_bigmem) = bigmem_guest::build_waste_memory();
//     let start = Instant::now();
//     let (_output, proof) = prove_bigmem(value);
//     let end = Instant::now();

//     (end.duration_since(start), proof.size().unwrap())
// }

fn benchmark_binary_search(n: usize) -> (Duration, usize) {
    let (prove_bs, _verify_bs) = binary_search_guest::build_find();

    let input: Vec<usize> = (1..=n).collect();

    let start = Instant::now();
    let (_output, proof) = prove_bs(&input);
    let end = Instant::now();

    (end.duration_since(start), proof.size().unwrap())
}
