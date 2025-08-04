use clap::Parser;
use std::sync::Arc;
use std::{time::Instant, usize};
use utils::{size, BenchmarkConfig, BenchmarkResult};

use openvm_algebra_circuit::ModularExtension;
use openvm_build::GuestOptions;
use openvm_ecc_circuit::{WeierstrassExtension, SECP256K1_CONFIG};
use openvm_sdk::{
    commit::AppExecutionCommit,
    config::{AggStarkConfig, AppConfig, SdkVmConfig},
    Sdk, StdIn,
};
use openvm_stark_sdk::config::FriParameters;

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
        program: cli.program.clone(),
        verifier_iterations: cli.verifier_iterations,
    };

    let result = match cli.program.as_str() {
        "fib" => benchmark_fib(&config),
        "sha2" => benchmark_sha2(&config),
        "sha2-precompile" => benchmark_sha2_precompile(&config),
        "sha2-chain" => benchmark_sha2_chain(&config),
        "sha2-chain-precompile" => benchmark_sha2_chain_precompile(&config),
        "sha3" => benchmark_sha3(&config),
        "sha3-precompile" => benchmark_sha3_precompile(&config),
        "sha3-chain" => benchmark_sha3_chain(&config),
        "sha3-chain-precompile" => benchmark_sha3_chain_precompile(&config),
        "mat-mul" => benchmark_mat_mul(&config),
        "ec" => benchmark_ec(&config),
        "ec-precompile" => benchmark_ec_precompile(&config),
        "blake" => benchmark_blake(&config),
        "blake-chain" => benchmark_blake_chain(&config),
        _ => unreachable!(),
    };
    std::fs::write("results.json", result.to_json()).unwrap();
}

fn prove_and_verify(
    target_path: &str,
    stdin: &mut StdIn,
    vm_config: SdkVmConfig,
    verifier_iterations: u32,
) -> BenchmarkResult {
    let sdk = Sdk::new();

    let guest_opts = GuestOptions::default();
    let elf = sdk
        .build(
            guest_opts,
            &vm_config,
            target_path,
            &Default::default(),
            None,
        )
        .unwrap();

    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();

    let output = sdk
        .execute(exe.clone(), vm_config.clone(), stdin.clone())
        .unwrap();
    println!("public values output: {:?}", output);

    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config.clone());
    let agg_stark_config = AggStarkConfig::default();

    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());
    let agg_stark_pk = sdk.agg_stark_keygen(agg_stark_config).unwrap();

    // Generate a proof
    let prover_start = Instant::now();
    let proof = sdk
        .generate_e2e_stark_proof(
            app_pk.clone(),
            app_committed_exe.clone(),
            agg_stark_pk.clone(),
            stdin.clone(),
        )
        .unwrap();
    let prover_end = Instant::now();
    let prover_duration = prover_end.duration_since(prover_start);

    // Verify your program multiple times
    let commits =
        AppExecutionCommit::compute(&vm_config, &app_committed_exe, &app_pk.leaf_committed_exe);
    let expected_exe_commit = commits.app_exe_commit.to_bn254();
    let expected_vm_commit = commits.app_vm_commit.to_bn254();

    let mut verifier_durations = Vec::new();
    for _ in 0..verifier_iterations {
        let verify_start = Instant::now();
        sdk.verify_e2e_stark_proof(
            &agg_stark_pk,
            &proof,
            &expected_exe_commit,
            &expected_vm_commit,
        )
        .unwrap();
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    let proof_size = size(&proof);

    // TO DO: Add cycle count
    let cycle_count = 0;

    BenchmarkResult {
        proof_size,
        prover_durations: vec![prover_duration],
        verifier_durations,
        cycle_count,
        ..Default::default()
    }
}

fn benchmark_fib(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "fib";

    let mut stdin = StdIn::default();
    stdin.write(&config.n);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_sha2(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "sha2";

    let input = vec![5u8; config.n as usize];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_sha2_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "sha2-precompile";

    let input = vec![5u8; config.n as usize];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .sha256(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_sha2_chain(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "sha2-chain";

    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&config.n);
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_sha2_chain_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "sha2-chain-precompile";

    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&config.n);
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .sha256(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_sha3(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "sha3";

    let input = vec![5u8; config.n as usize];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_sha3_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "sha3-precompile";

    let input = vec![5u8; config.n as usize];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .keccak(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_sha3_chain(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "sha3-chain";

    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&config.n);
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_sha3_chain_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "sha3-chain-precompile";

    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&config.n);
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .keccak(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_mat_mul(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "mat-mul";

    let mut stdin = StdIn::default();
    stdin.write(&config.n);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_ec(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "ec";

    let mut stdin = StdIn::default();
    stdin.write(&config.n);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_ec_precompile(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "ec-precompile";

    let mut stdin = StdIn::default();
    stdin.write(&config.n);

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

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_blake(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "blake";

    let input = vec![5u8; config.n as usize];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}

fn benchmark_blake_chain(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_path = "blake-chain";

    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&config.n);
    stdin.write(&input);

    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();

    prove_and_verify(
        target_path,
        &mut stdin,
        vm_config,
        config.verifier_iterations,
    )
}
