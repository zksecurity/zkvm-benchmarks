use std::{
    io::Write,
    time::{Duration, Instant},
};

use sp1_sdk::{include_elf, utils as sp1_utils, ProverClient, SP1Stdin};
use utils::size;

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
}

fn main() {
    sp1_utils::setup_logger();

    let cli = Cli::parse();

    let (duration, proof_size, verifier_duration, cycle_count) = match cli.program.as_str() {
        "fib" => bench_fibonacci(cli.n),
        "sha2" => benchmark_sha2(cli.n as usize),
        "sha2-precompile" => benchmark_sha2_precompile(cli.n as usize),
        "sha2-chain" => benchmark_sha2_chain(cli.n),
        "sha2-chain-precompile" => benchmark_sha2_chain_precompile(cli.n),
        "sha3" => benchmark_sha3(cli.n as usize),
        "sha3-precompile" => benchmark_sha3_precompile(cli.n as usize),
        "sha3-chain" => benchmark_sha3_chain(cli.n),
        "sha3-chain-precompile" => benchmark_sha3_chain_precompile(cli.n),
        "mat-mul" => bench_mat_mul(cli.n),
        "ec" => bench_ecadd(cli.n),
        "ec-precompile" => bench_ecadd_precompile(cli.n),
        _ => unreachable!(),
    };
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();
}

fn benchmark_sha2_chain(iters: u32) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&iters);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(SHA2_CHAIN_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA2_CHAIN_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn benchmark_sha2_chain_precompile(iters: u32) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&iters);

    let client = ProverClient::from_env();
    let (_, report) = client
        .execute(SHA2_CHAIN_PRECOMPILE_ELF, &stdin)
        .run()
        .unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA2_CHAIN_PRECOMPILE_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn benchmark_sha3_chain(iters: u32) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&iters);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(SHA3_CHAIN_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA3_CHAIN_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn benchmark_sha3_chain_precompile(iters: u32) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&iters);

    let client = ProverClient::from_env();
    let (_, report) = client
        .execute(SHA3_CHAIN_PRECOMPILE_ELF, &stdin)
        .run()
        .unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA3_CHAIN_PRECOMPILE_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn benchmark_sha2(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; num_bytes];
    stdin.write(&input);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(SHA2_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA2_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn benchmark_sha2_precompile(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; num_bytes];
    stdin.write(&input);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(SHA2_PRECOMPILE_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA2_PRECOMPILE_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn benchmark_sha3_precompile(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; num_bytes];
    stdin.write(&input);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(SHA3_PRECOMPILE_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA3_PRECOMPILE_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn benchmark_sha3(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; num_bytes];
    stdin.write(&input);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(SHA3_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA3_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn bench_fibonacci(n: u32) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    stdin.write(&n);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(FIBONACCI_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(FIBONACCI_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn bench_ecadd(n: u32) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    stdin.write(&n);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(ECADD_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(ECADD_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn bench_ecadd_precompile(n: u32) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    stdin.write(&n);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(ECADD_PRECOMPILE_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(ECADD_PRECOMPILE_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn bench_mat_mul(n: u32) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    stdin.write(&n);

    let client = ProverClient::from_env();
    let (_, report) = client.execute(MATMUL_ELF, &stdin).run().unwrap();
    let cycle_count = report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(MATMUL_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, &stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}
