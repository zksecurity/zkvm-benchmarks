use std::time::Duration;
use std::io::Write;
use methods::{
    MAT_MUL_ELF, MAT_MUL_ID
};
use risc0_zkvm::{default_prover, ExecutorEnv, ProverOpts};
use utils::{size};

fn main() {
    // read the first arg
    let args: Vec<String> = std::env::args().collect();
    let n = args.iter().position(|arg| arg == "--n")
        .and_then(|i| args.get(i + 1))
        .expect("Please provide --n <number>")
        .parse::<u32>()
        .expect("Invalid number");

    let (duration, proof_size, verifier_duration, cycle_count) = bench_mat_mul(n);
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();
}

fn bench_mat_mul(n: u32) -> (Duration, usize, Duration, usize) {
    let env = ExecutorEnv::builder().write::<u32>(&n).unwrap().build().unwrap();
    let prover = default_prover();

    let start = std::time::Instant::now();
    let prove_info = prover.prove_with_opts(env, MAT_MUL_ELF, &ProverOpts::succinct()).unwrap();
    let end = std::time::Instant::now();
    let duration = end.duration_since(start);

    let receipt = prove_info.receipt;
    let cycle_count = prove_info.stats.user_cycles as usize;

    let _output: u32 = receipt.journal.decode().unwrap();
    
    let verifier_start = std::time::Instant::now();
    receipt.verify(MAT_MUL_ID).unwrap();
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);
    
    (duration, size(&receipt), verifier_duration, cycle_count)
}

