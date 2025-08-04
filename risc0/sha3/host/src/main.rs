use clap::Parser;
use methods::{SHA3_BENCH_ELF, SHA3_BENCH_ID};
use risc0_zkvm::{default_prover, ExecutorEnv, ProverOpts};
use utils::{size, BenchmarkConfig, BenchmarkResult};

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
    let cli = Cli::parse();

    let config = BenchmarkConfig {
        n: cli.n,
        program: cli.program,
        verifier_iterations: cli.verifier_iterations,
    };

    let result = bench_sha3(&config);
    std::fs::write("results.json", result.to_json()).unwrap();
}

fn bench_sha3(config: &BenchmarkConfig) -> BenchmarkResult {
    let input = vec![5u8; config.n as usize];
    let env = ExecutorEnv::builder().write(&input).unwrap().build().unwrap();
    let prover = default_prover();

    let prover_start = std::time::Instant::now();
    let prove_info = prover.prove_with_opts(env, SHA3_BENCH_ELF, &ProverOpts::succinct()).unwrap();
    let prover_end = std::time::Instant::now();
    let prover_duration = prover_end.duration_since(prover_start);

    let receipt = prove_info.receipt;
    let cycle_count = prove_info.stats.user_cycles as usize;
    let proof_size = size(&receipt);

    let _output: [u8; 32] = receipt.journal.decode().unwrap();

    let mut verifier_durations = Vec::new();
    for _ in 0..config.verifier_iterations {
        let verifier_start = std::time::Instant::now();
        receipt.verify(SHA3_BENCH_ID).unwrap();
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

