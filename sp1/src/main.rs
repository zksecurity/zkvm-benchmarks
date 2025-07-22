use std::{
    io::Write,
    time::{Duration, Instant},
};

use sp1_sdk::{include_elf, utils as sp1_utils, ProverClient, SP1Stdin};
use utils::{size, BenchmarkConfig, BenchmarkResult};

const FIBONACCI_ELF: &[u8] = include_elf!("fib");
const SHA2_ELF: &[u8] = include_elf!("sha2");
const SHA2_PRECOMPILE_ELF: &[u8] = include_elf!("sha2-precompile");
const SHA2_CHAIN_ELF: &[u8] = include_elf!("sha2-chain");
const SHA2_CHAIN_PRECOMPILE_ELF: &[u8] = include_elf!("sha2-chain-precompile");
const SHA3_CHAIN_ELF: &[u8] = include_elf!("sha3-chain");
const SHA3_CHAIN_PRECOMPILE_ELF: &[u8] = include_elf!("sha3-chain-precompile");
const SHA3_ELF: &[u8] = include_elf!("sha3");
const SHA3_PRECOMPILE_ELF: &[u8] = include_elf!("sha3-precompile");
const MATMUL_ELF: &[u8] = include_elf!("mat-mul");
const ECADD_ELF: &[u8] = include_elf!("ec");
const ECADD_PRECOMPILE_ELF: &[u8] = include_elf!("ec-precompile");

use clap::Parser;

#[derive(Parser, Debug)]
#[clap()]
pub struct Cli {
    #[arg(long)]
    pub n: u32,

    #[arg(long)]
    pub program: String,
    
    #[arg(long, default_value = "1")]
    pub verifier_iterations: u32,
}

fn main() {
    sp1_utils::setup_logger();

    let cli = Cli::parse();
    
    let config = BenchmarkConfig {
        n: cli.n,
        program: cli.program.clone(),
        verifier_iterations: cli.verifier_iterations,
    };

    let result = match cli.program.as_str() {
        "fib" => bench_fibonacci(&config),
        "sha2" => benchmark_sha2(&config),
        "sha2-precompile" => benchmark_sha2_precompile(&config),
        "sha2-chain" => benchmark_sha2_chain(&config),
        "sha2-chain-precompile" => benchmark_sha2_chain_precompile(&config),
        "sha3" => benchmark_sha3(&config),
        "sha3-precompile" => benchmark_sha3_precompile(&config),
        "sha3-chain" => benchmark_sha3_chain(&config),
        "sha3-chain-precompile" => benchmark_sha3_chain_precompile(&config),
        "mat-mul" => bench_mat_mul(&config),
        "ec" => bench_ecadd(&config),
        "ec-precompile" => bench_ecadd_precompile(&config),
        _ => unreachable!(),
    };
    
    std::fs::write("results.json", result.to_json()).unwrap();
}

fn prove_and_verify(
    stdin: &mut SP1Stdin,
    elf: &[u8],
    verifier_iterations: u32,
) -> BenchmarkResult {
    let client = ProverClient::from_env();
    let (_, report) = client.execute(elf, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(elf);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).compressed().run().unwrap();
    let end = Instant::now();
    let prover_duration = end.duration_since(start);
    let proof_size = size(&proof);

    let mut verifier_durations = Vec::new();
    for _ in 0..verifier_iterations {
        let verifier_start = std::time::Instant::now();
        client.verify(&proof, &vk).expect("verification failed");
        let verifier_end = std::time::Instant::now();
        verifier_durations.push(verifier_end.duration_since(verifier_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![prover_duration],
        verifier_durations,
        cycle_count,
        ..Default::default()
    }
}

fn benchmark_sha2_chain(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&config.n);
    prove_and_verify(&mut stdin, SHA2_CHAIN_ELF, config.verifier_iterations)
}

fn benchmark_sha2_chain_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&config.n);
    prove_and_verify(&mut stdin, SHA2_CHAIN_PRECOMPILE_ELF, config.verifier_iterations)
}

fn benchmark_sha3_chain(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&config.n);
    prove_and_verify(&mut stdin, SHA3_CHAIN_ELF, config.verifier_iterations)
}

fn benchmark_sha3_chain_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&config.n);
    prove_and_verify(&mut stdin, SHA3_CHAIN_PRECOMPILE_ELF, config.verifier_iterations)
}

fn benchmark_sha2(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; config.n as usize];
    stdin.write(&input);
    prove_and_verify(&mut stdin, SHA2_ELF, config.verifier_iterations)
}

fn benchmark_sha2_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; config.n as usize];
    stdin.write(&input);
    prove_and_verify(&mut stdin, SHA2_PRECOMPILE_ELF, config.verifier_iterations)
}

fn benchmark_sha3_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; config.n as usize];
    stdin.write(&input);
    prove_and_verify(&mut stdin, SHA3_PRECOMPILE_ELF, config.verifier_iterations)
}

fn benchmark_sha3(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; config.n as usize];
    stdin.write(&input);
    prove_and_verify(&mut stdin, SHA3_ELF, config.verifier_iterations)
}

fn bench_fibonacci(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    stdin.write(&config.n);
    prove_and_verify(&mut stdin, FIBONACCI_ELF, config.verifier_iterations)
}

fn bench_ecadd(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    stdin.write(&config.n);
    prove_and_verify(&mut stdin, ECADD_ELF, config.verifier_iterations)
}

fn bench_ecadd_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    stdin.write(&config.n);
    prove_and_verify(&mut stdin, ECADD_PRECOMPILE_ELF, config.verifier_iterations)
}

fn bench_mat_mul(config: &BenchmarkConfig) -> BenchmarkResult {
    let mut stdin = SP1Stdin::new();
    stdin.write(&config.n);
    prove_and_verify(&mut stdin, MATMUL_ELF, config.verifier_iterations)
}
