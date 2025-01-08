use std::time::Duration;
use std::io::Write;
use methods::{
    BINARY_SEARCH_ELF, BINARY_SEARCH_ID
};
use risc0_zkvm::{default_prover, ExecutorEnv};
use utils::{size};

fn main() {
    // read the first arg
    let args: Vec<String> = std::env::args().collect();
    let n = args.iter().position(|arg| arg == "--n")
        .and_then(|i| args.get(i + 1))
        .expect("Please provide --n <number>")
        .parse::<usize>()
        .expect("Invalid number");

    let (duration, proof_size) = bench_binary_search(n);
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}}}", proof_size, duration.as_millis()).as_bytes()).unwrap();
}

fn bench_binary_search(n: usize) -> (Duration, usize) {
    let input: Vec<usize> = (1..=n).collect();

    let env = ExecutorEnv::builder().write::<Vec<usize>>(&input).unwrap().build().unwrap();
    let prover = default_prover();

    let start = std::time::Instant::now();
    let receipt = prover.prove(env, BINARY_SEARCH_ELF).unwrap().receipt;
    let end = std::time::Instant::now();
    let duration = end.duration_since(start);

    let _output: u32 = receipt.journal.decode().unwrap();
    receipt.verify(BINARY_SEARCH_ID).unwrap();
    
    (duration, size(&receipt))
}

