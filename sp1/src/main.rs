use std::{io::Write, time::{Duration, Instant}};

use sp1_sdk::{utils as sp1_utils, ProverClient, SP1Stdin};
use utils::{size};

const FIBONACCI_ELF: &[u8] = include_bytes!("../fibonacci/elf/riscv32im-succinct-zkvm-elf");
const SHA2_ELF: &[u8] = include_bytes!("../sha2/elf/riscv32im-succinct-zkvm-elf");
const SHA2_CHAIN_ELF: &[u8] = include_bytes!("../sha2-chain/elf/riscv32im-succinct-zkvm-elf");
const SHA3_CHAIN_ELF: &[u8] = include_bytes!("../sha2-chain/elf/riscv32im-succinct-zkvm-elf");
const SHA3_ELF: &[u8] = include_bytes!("../sha3/elf/riscv32im-succinct-zkvm-elf");
const BIGMEM_ELF: &[u8] = include_bytes!("../bigmem/elf/riscv32im-succinct-zkvm-elf");

use clap::{Parser};

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

    // // 1 Shard
    // let iters = [230, /* 460, 920, 1840, 3680 */ ];
    // let shard_sizes = [1 << 20, /* 1 << 21, 1 << 22, 1 << 23, 1 << 24 */]; // Max shard_size = 2^24-1
    // // let iters = [230, 460, 920, 1840, /* 3680 */];
    // // let shard_sizes = [1 << 20, 1 << 21, 1 << 22, 1 << 23, /* 1 << 24 */];
    // benchmark_with_shard_size(benchmark_sha2_chain, &iters, &shard_sizes, "../benchmark_outputs/sha2_chain_sp1_1_shard.csv", "iters");

    // // 2 Shards
    // let iters = [230, 460, 920, 1840, 3680];
    // let shard_sizes = [1 << 19, 1 << 20, 1 << 21, 1 << 22, 1 << 23];
    // benchmark_with_shard_size(benchmark_sha2_chain, &iters, &shard_sizes, "../benchmark_outputs/sha2_chain_sp1_2_shard.csv", "iters");

    // // 4 Shards
    // let shard_sizes = [1 << 18, 1 << 19, 1 << 20, 1 << 21, 1 << 22];
    // benchmark_with_shard_size(benchmark_sha2_chain, &iters, &shard_sizes, "../benchmark_outputs/sha2_chain_sp1_4_shard.csv", "iters");

    // // 8 Shards
    // let shard_sizes = [1 << 17, 1 << 18, 1 << 19, 1 << 20, 1 << 21];
    // benchmark_with_shard_size(benchmark_sha2_chain, &iters, &shard_sizes, "../benchmark_outputs/sha2_chain_sp1_8_shard.csv", "iters");

    // // 16 Shards
    // let shard_sizes = [1 << 16, 1 << 17, 1 << 18, 1 << 19, 1 << 20];
    // benchmark_with_shard_size(benchmark_sha2_chain, &iters, &shard_sizes, "../benchmark_outputs/sha2_chain_sp1_16_shard.csv", "iters");

    // benchmark(benchmark_sha3_chain, &iters, "../benchmark_outputs/sha3_chain_sp1.csv", "iters");

    // let lengths = [32, 256, 512, 1024, 2048];
    // benchmark(benchmark_sha2, &lengths, "../benchmark_outputs/sha2_sp1.csv", "byte length");
    // benchmark(benchmark_sha3, &lengths, "../benchmark_outputs/sha3_sp1.csv", "byte length");

    // let ns = [100, 1000, 10000, 50000];
    // let ns = [50];
    // benchmark(bench_fibonacci, &ns, "../benchmark_outputs/fibonacci_sp1.csv", "n");

    let cli = Cli::parse();

    // let proof_size = if cli.program == "fib" {
    //     let (_, size) = bench_fibonacci(cli.n);
    //     size
    // } else {
    //     0
    // };

    let (duration, proof_size) = match cli.program.as_str() {
        "fib" => {
            bench_fibonacci(cli.n)
        },
        "sha2" => {
            benchmark_sha2(cli.n as usize)
        },
        "sha3" => {
            benchmark_sha3(cli.n as usize)
        },
        _ => unreachable!()

    };

    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}}}", proof_size, duration.as_millis()).as_bytes()).unwrap();

    // let values = [5u32];
    // benchmark(bench_bigmem, &values, "../benchmark_outputs/bigmem_sp1.csv", "value");
}

fn benchmark_with_shard_size(func: fn(u32) -> (Duration, usize), iters: &[u32], shard_sizes: &[usize], file_name: &str, input_name: &str) {
    assert_eq!(iters.len(), shard_sizes.len());
    let mut info = Vec::new();
    for bench_i in 0..iters.len() {
        std::env::set_var("SHARD_SIZE", format!("{}", shard_sizes[bench_i]));
        let duration_and_size = func(iters[bench_i]);
        info.push(duration_and_size);
    }
    utils::write_csv(file_name, input_name, iters, &info);
}

fn benchmark_sha2_chain(iters: u32) -> (Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&iters);

    let client = ProverClient::new();
    let (pk, vk) = client.setup(SHA2_CHAIN_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    client.verify(&proof, &vk).expect("verification failed");

    (duration, size(&proof))
}

fn benchmark_sha3_chain(iters: u32) -> (Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = [5u8; 32];
    stdin.write(&input);
    stdin.write(&iters);

    let client = ProverClient::new();
    let (pk, vk) = client.setup(SHA3_CHAIN_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    client.verify(&proof, &vk).expect("verification failed");

    (duration, size(&proof))
}

fn benchmark_sha2(num_bytes: usize) -> (Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; num_bytes];
    stdin.write(&input);

    let client = ProverClient::new();
    let (pk, vk) = client.setup(SHA2_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    client.verify(&proof, &vk).expect("verification failed");

    (duration, size(&proof))
}

fn benchmark_sha3(num_bytes: usize) -> (Duration, usize) {
    let mut stdin = SP1Stdin::new();
    let input = vec![5u8; num_bytes];
    stdin.write(&input);

    let client = ProverClient::new();
    let (pk, vk) = client.setup(SHA3_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    client.verify(&proof, &vk).expect("verification failed");

    (duration, size(&proof))
}

fn bench_fibonacci(n: u32) -> (Duration, usize) {
    let mut stdin = SP1Stdin::new();
    stdin.write(&n);

    let client = ProverClient::new();
    let (pk, vk) = client.setup(FIBONACCI_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    client.verify(&proof, &vk).expect("verification failed");

    (duration, size(&proof))
}

fn bench_bigmem(value: u32) -> (Duration, usize) {
    let mut stdin = SP1Stdin::new();
    stdin.write(&value);

    let client = ProverClient::new();
    let (pk, vk) = client.setup(BIGMEM_ELF);

    let start = Instant::now();
    let proof = client.prove(&pk, stdin).run().unwrap();
    let end = Instant::now();
    let duration = end.duration_since(start);

    client.verify(&proof, &vk).expect("verification failed");

    (duration, size(&proof))
}
