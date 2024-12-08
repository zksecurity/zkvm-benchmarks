use std::time::Duration;

use methods::{
    FIBONACCI_ELF, FIBONACCI_ID
};
use risc0_zkvm::{default_prover, ExecutorEnv};
use utils::{benchmark, size};

fn main() {
    // let ns = [100, 1000, 10000, 50000];
    let ns = [50];
    benchmark(bench_fibonacci, &ns, "../../benchmark_outputs/fibonacci_risczero.csv", "n");
}

fn bench_fibonacci(n: u32) -> (Duration, Duration, usize) {
    let env = ExecutorEnv::builder().write::<u32>(&n).unwrap().build().unwrap();
    let prover = default_prover();

    let start = std::time::Instant::now();
    let receipt = prover.prove(env, FIBONACCI_ELF).unwrap().receipt;
    let end = std::time::Instant::now();
    let prover_time = end.duration_since(start);

    let _output: u32 = receipt.journal.decode().unwrap();
    let verify_start = std::time::Instant::now();
    receipt.verify(FIBONACCI_ID).unwrap();
    let verify_end = std::time::Instant::now();
    let verifier_time = verify_end.duration_since(verify_start);
    
    (prover_time, verifier_time, size(&receipt))
}

