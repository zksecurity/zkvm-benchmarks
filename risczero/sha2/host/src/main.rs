use std::time::Duration;

use methods::{SHA2_BENCH_ELF, SHA2_BENCH_ID};
use risc0_zkvm::{default_prover, ExecutorEnv};
use utils::{benchmark, size};

fn main() {
    let lengths = [32, 256, 512, 1024, 2048];
    benchmark(bench_sha2, &lengths, "../../benchmark_outputs/sha2_risczero.csv", "n");
}

fn bench_sha2(num_bytes: usize) -> (Duration, Duration, usize) {
    let input = vec![5u8; num_bytes];
    let env = ExecutorEnv::builder().write(&input).unwrap().build().unwrap();
    let prover = default_prover();

    let start = std::time::Instant::now();
    let receipt = prover.prove(env, SHA2_BENCH_ELF).unwrap().receipt;
    let end = std::time::Instant::now();
    let prover_time = end.duration_since(start);

    let _output: u32 = receipt.journal.decode().unwrap();
    let verify_start = std::time::Instant::now();
    receipt.verify(SHA2_BENCH_ID).unwrap();
    let verify_end = std::time::Instant::now();
    let verifier_time = verify_end.duration_since(verify_start);
    
    (prover_time, verifier_time, size(&receipt))
}

