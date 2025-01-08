use std::time::Duration;

use methods::{SHA2_BENCH_ELF, SHA2_BENCH_ID};
use risc0_zkvm::{default_prover, ExecutorEnv};
use utils::{benchmark, size};
use std::io::Write;

fn main() {
    // read the first arg
    let args: Vec<String> = std::env::args().collect();
    let n = args.iter().position(|arg| arg == "--n")
        .and_then(|i| args.get(i + 1))
        .expect("Please provide --n <number>")
        .parse::<usize>()
        .expect("Invalid number");

    let (duration, proof_size) = bench_sha2(n);
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}}}", proof_size, duration.as_millis()).as_bytes()).unwrap();
}

fn bench_sha2(num_bytes: usize) -> (Duration, usize) {
    let input = vec![5u8; num_bytes];
    let env = ExecutorEnv::builder().write(&input).unwrap().build().unwrap();
    let prover = default_prover();

    let start = std::time::Instant::now();
    let receipt = prover.prove(env, SHA2_BENCH_ELF).unwrap().receipt;
    let end = std::time::Instant::now();
    let duration = end.duration_since(start);

    let _output: [u8; 32] = receipt.journal.decode().unwrap();
    receipt.verify(SHA2_BENCH_ID).unwrap();

    (duration, size(&receipt))
}

// refactor benchmark
// create a benchmark binary
// - run cargo build --release in the current folder
// - run benchmark [binary], the built binary