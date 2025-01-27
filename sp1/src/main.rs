use std::{io::Write, time::{Duration, Instant}};

use sp1_sdk::{utils as sp1_utils, ProverClient, SP1Stdin};
use utils::size;

const FIBONACCI_ELF: &[u8] = include_bytes!("../fibonacci/elf/riscv32im-succinct-zkvm-elf");
const SHA2_ELF: &[u8] = include_bytes!("../sha2/elf/riscv32im-succinct-zkvm-elf");
const SHA2_PRECOMPILE_ELF: &[u8] = include_bytes!("../sha2-precompile/elf/riscv32im-succinct-zkvm-elf");
const SHA2_CHAIN_ELF: &[u8] = include_bytes!("../sha2-chain/elf/riscv32im-succinct-zkvm-elf");
const SHA2_CHAIN_PRECOMPILE_ELF: &[u8] = include_bytes!("../sha2-chain-precompile/elf/riscv32im-succinct-zkvm-elf");
const SHA3_CHAIN_ELF: &[u8] = include_bytes!("../sha2-chain/elf/riscv32im-succinct-zkvm-elf");
const SHA3_CHAIN_PRECOMPILE_ELF: &[u8] = include_bytes!("../sha3-chain-precompile/elf/riscv32im-succinct-zkvm-elf");
const SHA3_ELF: &[u8] = include_bytes!("../sha3/elf/riscv32im-succinct-zkvm-elf");
const SHA3_PRECOMPILE_ELF: &[u8] = include_bytes!("../sha3-precompile/elf/riscv32im-succinct-zkvm-elf");
const MATMUL_ELF: &[u8] = include_bytes!("../mat-mul/elf/riscv32im-succinct-zkvm-elf");
const BINARY_SEARCH_ELF: &[u8] = include_bytes!("../binary-search/elf/riscv32im-succinct-zkvm-elf");
const ECADD_ELF: &[u8] = include_bytes!("../ec/elf/riscv32im-succinct-zkvm-elf");

use clap::Parser;

/// A tool to build and optionally benchmark a cargo project
#[derive(Parser, Debug)]
#[clap()]
pub struct Cli {
    #[arg(long)]
    pub n: u32,
    
    /// Run the benchmark under heaptrack for memory profiling
    #[arg(long)]
    pub program: String,
}


fn main() {
    sp1_utils::setup_logger();

    let cli = Cli::parse();

    let (duration, proof_size, verifier_duration, cycle_count) = match cli.program.as_str() {
        "fib" => {
            bench_fibonacci(cli.n)
        },
        "sha2" => {
            benchmark_sha2(cli.n as usize)
        },
        "sha2-precompile" => {
            benchmark_sha2_precompile(cli.n as usize)
        },
        "sha2-chain" => {
            benchmark_sha2_chain(cli.n)
        },
        "sha2-chain-precompile" => {
            benchmark_sha2_chain_precompile(cli.n)
        },
        "sha3" => {
            benchmark_sha3(cli.n as usize)
        },
        "sha3-precompile" => {
            benchmark_sha3_precompile(cli.n as usize)
        },
        "sha3-chain" => {
            benchmark_sha3_chain(cli.n)
        },
        "sha3-chain-precompile" => {
            benchmark_sha3_chain_precompile(cli.n)
        },
        "mat-mul" => {
            bench_mat_mul(cli.n)
        },
        "binary-search" => {
            benchmark_binary_search(cli.n as usize)
        },
        "ecadd" => {
            bench_ecadd(cli.n)
        }
        _ => unreachable!()

    };
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();

}

fn _benchmark_with_shard_size(func: fn(u32) -> (Duration, usize), iters: &[u32], shard_sizes: &[usize], file_name: &str, input_name: &str) {
    assert_eq!(iters.len(), shard_sizes.len());
    let mut info = Vec::new();
    for bench_i in 0..iters.len() {
        std::env::set_var("SHARD_SIZE", format!("{}", shard_sizes[bench_i]));
        let duration_and_size = func(iters[bench_i]);
        info.push(duration_and_size);
    }
    utils::write_csv(file_name, input_name, iters, &info);
}

fn benchmark_sha2_chain(iters: u32) -> (Duration, usize, Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&iters);

    let client = ProverClient::new();
    let (_, report) = client.execute(SHA2_CHAIN_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA2_CHAIN_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(SHA2_CHAIN_PRECOMPILE_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA2_CHAIN_PRECOMPILE_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(SHA3_CHAIN_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA3_CHAIN_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(SHA3_CHAIN_PRECOMPILE_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA3_CHAIN_PRECOMPILE_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(SHA2_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA2_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(SHA2_PRECOMPILE_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA2_PRECOMPILE_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(SHA3_PRECOMPILE_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA3_PRECOMPILE_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(SHA3_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(SHA3_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(FIBONACCI_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(FIBONACCI_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(ECADD_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(ECADD_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}

fn benchmark_binary_search(n: usize) -> (Duration, usize, Duration, usize) {
    let input: Vec<usize> = (1..=n).collect();
    
    let mut stdin = SP1Stdin::new();
    stdin.write(&input);

    let client = ProverClient::new();
    let (_, report) = client.execute(BINARY_SEARCH_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(BINARY_SEARCH_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
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

    let client = ProverClient::new();
    let (_, report) = client.execute(MATMUL_ELF, stdin.clone()).run().unwrap();
    let cycle_count =  report.total_instruction_count() as usize;
    let (pk, vk) = client.setup(MATMUL_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    let verifier_start = std::time::Instant::now();
    client.verify(&proof, &vk).expect("verification failed");
    let verifier_end = std::time::Instant::now();
    let verifier_duration = verifier_end.duration_since(verifier_start);

    (duration, size(&proof), verifier_duration, cycle_count)
}