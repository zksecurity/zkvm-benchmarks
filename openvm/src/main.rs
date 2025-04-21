use std::{io::Write, time::{Duration, Instant}, usize};
use clap::Parser;
use utils::size;
use std::sync::Arc;

use openvm_build::GuestOptions;
use openvm_sdk::{
    config::{AppConfig, SdkVmConfig},
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
        _ => unreachable!()

    };
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();
}

fn benchmark_fib(n: u32) -> (Duration, usize, Duration, usize) {
    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "fib";
    let elf = sdk.build(guest_opts, target_path, &Default::default()).unwrap();

    // 3. Transpile the ELF into a VmExe
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();
    
    // 4. Format your input into StdIn
    let mut stdin = StdIn::default();
    stdin.write(&n);

    // 5. Run the program
    let output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();
    println!("public values output: {:?}", output);

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}

fn benchmark_sha2(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "sha2";
    let elf = sdk.build(guest_opts, target_path, &Default::default()).unwrap();

    // 3. Transpile the ELF into a VmExe
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();
    
    // 4. Format your input into StdIn
    let input = vec![5u8; num_bytes];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    // 5. Run the program
    let _output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}

fn benchmark_sha2_precompile(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .sha256(Default::default())
        .build();

    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "sha2-precompile";
    let elf = sdk
        .build(guest_opts, target_path, &Default::default())
        .unwrap();

    // 3. Transpile the ELF into a VmExe
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();

    // 4. Format your input into StdIn
    let input = vec![5u8; num_bytes];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    // 5. Run the program
    let _output = sdk
        .execute(exe.clone(), vm_config.clone(), stdin.clone())
        .unwrap();

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}

fn benchmark_sha2_chain(n: u32) -> (Duration, usize, Duration, usize) {
    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "sha2-chain";
    let elf = sdk.build(guest_opts, target_path, &Default::default()).unwrap();

    // 3. Transpile the ELF into a VmExe
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();
    
    // 4. Format your input into StdIn
    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&n);
    stdin.write(&input);

    // 5. Run the program
    let _output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}

fn benchmark_sha2_chain_precompile(n: u32) -> (Duration, usize, Duration, usize) {
    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "sha2-chain-precompile";
    let elf = sdk.build(guest_opts, target_path, &Default::default()).unwrap();

    // 3. Transpile the ELF into a VmExe
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .sha256(Default::default())
        .build();
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();
    
    // 4. Format your input into StdIn
    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&n);
    stdin.write(&input);

    // 5. Run the program
    let _output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}

fn benchmark_sha3(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "sha3";
    let elf = sdk.build(guest_opts, target_path, &Default::default()).unwrap();

    // 3. Transpile the ELF into a VmExe
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();
    
    // 4. Format your input into StdIn
    let input = vec![5u8; num_bytes];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    // 5. Run the program
    let _output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}

fn benchmark_sha3_precompile(num_bytes: usize) -> (Duration, usize, Duration, usize) {
    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "sha3-precompile";
    let elf = sdk.build(guest_opts, target_path, &Default::default()).unwrap();

    // 3. Transpile the ELF into a VmExe
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .keccak(Default::default())
        .build();
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();
    
    // 4. Format your input into StdIn
    let input = vec![5u8; num_bytes];
    let mut stdin = StdIn::default();
    stdin.write(&input);

    // 5. Run the program
    let _output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}

fn benchmark_sha3_chain(n: u32) -> (Duration, usize, Duration, usize) {
    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "sha3-chain";
    let elf = sdk.build(guest_opts, target_path, &Default::default()).unwrap();

    // 3. Transpile the ELF into a VmExe
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();
    
    // 4. Format your input into StdIn
    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&n);
    stdin.write(&input);

    // 5. Run the program
    let _output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}

fn benchmark_sha3_chain_precompile(n: u32) -> (Duration, usize, Duration, usize) {
    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "sha3-chain-precompile";
    let elf = sdk.build(guest_opts, target_path, &Default::default()).unwrap();

    // 3. Transpile the ELF into a VmExe
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .keccak(Default::default())
        .build();
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();
    
    // 4. Format your input into StdIn
    let input = vec![5u8; 32];
    let mut stdin = StdIn::default();
    stdin.write(&n);
    stdin.write(&input);

    // 5. Run the program
    let _output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}

fn benchmark_mat_mul(dim: u32) -> (Duration, usize, Duration, usize) {
    // 1. Build the VmConfig with the extensions needed.
    let sdk = Sdk::new();

    // 2a. Build the ELF with guest options and a target filter.
    let guest_opts = GuestOptions::default();
    let target_path = "mat-mul";
    let elf = sdk.build(guest_opts, target_path, &Default::default()).unwrap();

    // 3. Transpile the ELF into a VmExe
    let vm_config = SdkVmConfig::builder()
        .system(Default::default())
        .rv32i(Default::default())
        .rv32m(Default::default())
        .io(Default::default())
        .build();
    let exe = sdk.transpile(elf, vm_config.transpiler()).unwrap();
    
    // 4. Format your input into StdIn
    let mut stdin = StdIn::default();
    stdin.write(&dim);

    // 5. Run the program
    let _output = sdk.execute(exe.clone(), vm_config.clone(), stdin.clone()).unwrap();

    // 6. Set app configuration
    let app_log_blowup = 2;
    let app_fri_params = FriParameters::standard_with_100_bits_conjectured_security(app_log_blowup);
    let app_config = AppConfig::new(app_fri_params, vm_config);

    // 7. Commit the exe
    let app_committed_exe = sdk.commit_app_exe(app_fri_params, exe).unwrap();

    // 8. Generate an AppProvingKey
    let app_pk = Arc::new(sdk.app_keygen(app_config).unwrap());

    // 9a. Generate a proof
    let start = Instant::now();
    let proof = sdk.generate_app_proof(app_pk.clone(), app_committed_exe.clone(), stdin.clone()).unwrap();
    let end = Instant::now();

    // 10. Verify your program
    let app_vk = app_pk.get_app_vk();
    let verify_start = Instant::now();
    sdk.verify_app_proof(&app_vk, &proof).unwrap();
    let verify_end = Instant::now();

    let proof_size = size(&proof);
    
    // TO DO: Add cycle count
    let cycle_count = 0;

    (end.duration_since(start), proof_size, verify_end.duration_since(verify_start), cycle_count)
}