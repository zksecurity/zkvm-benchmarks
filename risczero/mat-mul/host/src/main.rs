use std::time::Duration;
use std::io::Write;
use methods::{
    MAT_MUL_ELF, MAT_MUL_ID
};
use risc0_zkvm::{default_prover, ExecutorEnv};
use utils::{size};

fn main() {
    // read the first arg
    let args: Vec<String> = std::env::args().collect();
    let n = args.iter().position(|arg| arg == "--n")
        .and_then(|i| args.get(i + 1))
        .expect("Please provide --n <number>")
        .parse::<u32>()
        .expect("Invalid number");

    let (duration, proof_size) = bench_mat_mul(n);
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\":{}}}", proof_size, duration.as_millis()).as_bytes()).unwrap();
}

fn bench_mat_mul(n: u32) -> (Duration, usize) {
    let env = ExecutorEnv::builder().write::<u32>(&n).unwrap().build().unwrap();
    let prover = default_prover();

    let start = std::time::Instant::now();
    let receipt = prover.prove(env, MAT_MUL_ELF).unwrap().receipt;
    let end = std::time::Instant::now();
    let duration = end.duration_since(start);

    let _output: u32 = receipt.journal.decode().unwrap();
    receipt.verify(MAT_MUL_ID).unwrap();
    
    (duration, size(&receipt))
}

