use std::time::Duration;

use methods::{
    BIGMEM_ELF, BIGMEM_ID
};
use risc0_zkvm::{default_prover, ExecutorEnv};
use utils::{benchmark, size};

fn main() {
    let values = [5];
    benchmark(bench_bigmem, &values, "../../benchmark_outputs/bigmem_risczero.csv", "n");
}

fn bench_bigmem(n: u32) -> (Duration, Duration, usize) {
    let env = ExecutorEnv::builder().write::<u32>(&n).unwrap().build().unwrap();
    let prover = default_prover();

    let start = std::time::Instant::now();
    let receipt = prover.prove(env, BIGMEM_ELF).unwrap().receipt;
    let end = std::time::Instant::now();
    let prover_time = end.duration_since(start);

    let _output: u32 = receipt.journal.decode().unwrap();
    let verify_start = std::time::Instant::now();
    receipt.verify(BIGMEM_ID).unwrap();
    let verify_end = std::time::Instant::now();
    let verifier_time = verify_end.duration_since(verify_start);
    
    (prover_time, verifier_time, size(&receipt))
}

