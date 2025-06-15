use std::{io::Write, time::{Duration, Instant}, usize};
use clap::Parser;
use utils::size;
use std::sync::Arc;

use openvm_build::GuestOptions;
use openvm_sdk::{
    config::{AppConfig, SdkVmConfig, AggStarkConfig},
    commit::AppExecutionCommit,
    Sdk, StdIn,
};
use openvm_stark_sdk::config::FriParameters;
use openvm_ecc_circuit::{SECP256K1_CONFIG, WeierstrassExtension};
use openvm_algebra_circuit::ModularExtension;

#[derive(Parser, Debug)]
#[clap()]
pub struct Cli {
    #[arg(long)]
    pub n: u32,
    
    #[arg(long)]
    pub program: String,
}

fn main() {
    let cli = Cli::parse();

    let (duration, proof_size, verifier_duration, cycle_count) = match cli.program.as_str() {
        "fib" => {
            benchmark_fib(cli.n)
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
            benchmark_mat_mul(cli.n)
        },
        "ec" => {
            benchmark_ec(cli.n)
        },
        "ec-precompile" => {
            benchmark_ec_precompile(cli.n)
        },
        _ => unreachable!()

    };
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();
}

fn prove_and_verify(
    target_path: &str,
    stdin: &mut StdIn,
    vm_config: SdkVmConfig,
) -> (Duration, usize, Duration, usize) {
    
    let sdk = Sdk::new();

    let guest_opts = GuestOptions::default();
    let elf = sdk.build(
        guest_opts,
        &vm_config,
        target_path,
        &Default::default(),
        None,
    ).unwrap();

    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();

    let output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();
    println!("public values output: {:?}", output);

    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config.clone());
    let agg_stark_config = AggStarkConfig::default();

    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());
    let agg_stark_pk = sdk.agg_stark_keygen(agg_stark_config).unwrap();

    // Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_e2e_stark_proof(app_pk.clone(), app_committed_exe.clone(), agg_stark_pk.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // Verify your program
    let commits = AppExecutionCommit::compute(&vm_config, &app_committed_exe, &app_pk.leaf_committed_exe);
    let expected_exe_commit = commits.app_exe_commit.to_bn254();
    let expected_vm_commit = commits.app_vm_commit.to_bn254();
    
    let verify_start = Instant::now();
    sdk.verify_e2e_stark_proof(
        &agg_stark_pk,
        &proof,
        &expected_exe_commit,
        &expected_vm_commit,
    ).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)

}

fn benchmark_fib(n: u32) -> (Duration, usize, Duration, usize) {
    let target_path = "fib";
    
    let mut stdin = StdIn::default();
    stdin.write(&n);
    
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_sha2(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let target_path = "sha2";

    let input = vec![5u8; num_bytes];
    let mut stdin = StdIn::default();
    stdin.write(&input);
    
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_sha2_precompile(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let target_path = "sha2-precompile";

    let input = vec![5u8; num_bytes];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .sha256(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_sha2_chain(n: u32) -> (Duration, usize, Duration, usize) {
    let target_path = "sha2-chain";

    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&n);
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_sha2_chain_precompile(n: u32) -> (Duration, usize, Duration, usize) {
    let target_path = "sha2-chain-precompile";
    
    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&n);
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .sha256(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_sha3(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let target_path = "sha3";

    let input = vec![5u8; num_bytes];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_sha3_precompile(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let target_path = "sha3-precompile";

    let input = vec![5u8; num_bytes];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .keccak(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_sha3_chain(n: u32) -> (Duration, usize, Duration, usize) {
    let target_path = "sha3-chain";
    
    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&n);
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_sha3_chain_precompile(n: u32) -> (Duration, usize, Duration, usize) {
    let target_path = "sha3-chain-precompile";

    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&n);
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .keccak(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_mat_mul(dim: u32) -> (Duration, usize, Duration, usize) {
    let target_path = "mat-mul";

    let mut stdin = StdIn::default();
    stdin.write(&dim);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_ec(n: u32) -> (Duration, usize, Duration, usize) {
    let target_path = "ec";

    let mut stdin = StdIn::default();
    stdin.write(&n);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}

fn benchmark_ec_precompile(n: u32) -> (Duration, usize, Duration, usize) {
    let target_path = "ec-precompile";

    let mut stdin = StdIn::default();
    stdin.write(&n);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .modular(ModularExtension::new(vec![
            SECP256K1_CONFIG.modulus.clone(),
            SECP256K1_CONFIG.scalar.clone(),
        ]))
        .ecc(WeierstrassExtension::new(vec![SECP256K1_CONFIG.clone()]))
        .build();

    prove_and_verify(target_path, &mut stdin, vm_config)
}