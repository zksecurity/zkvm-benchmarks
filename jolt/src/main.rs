use std::{time::Instant, usize};

use ark_serialize::{CanonicalDeserialize, CanonicalSerialize, Compress, Validate};
use jolt::{JoltHyperKZGProof, Serializable};
use utils::{BenchmarkConfig, BenchmarkResult};

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
    let cli = Cli::parse();

    let config = BenchmarkConfig {
        n: cli.n,
        program: cli.program.clone(),
        verifier_iterations: cli.verifier_iterations,
    };

    let result = match cli.program.as_str() {
        "fib" => benchmark_fib(&config),
        "sha2" => benchmark_sha2(&config),
        "sha2-chain" => benchmark_sha2_chain(&config),
        "sha3" => benchmark_sha3(&config),
        "sha3-chain" => benchmark_sha3_chain(&config),
        "mat-mul" => benchmark_mat_mul(&config),
        "ec" => benchmark_ecadd(&config),
        "blake" => benchmark_blake(&config),
        "blake-chain" => benchmark_blake_chain(&config),
        _ => unreachable!(),
    };

    std::fs::write("results.json", result.to_json()).unwrap();
}

fn benchmark_sha2_chain(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = sha2_chain_guest::compile_sha2_chain(target_dir);

    let prover_preprocessing = sha2_chain_guest::preprocess_prover_sha2_chain(&program);
    let verifier_preprocessing = sha2_chain_guest::preprocess_verifier_sha2_chain(&program);

    let prove_sha2_chain = sha2_chain_guest::build_prover_sha2_chain(program, prover_preprocessing);
    let verify_sha2_chain = sha2_chain_guest::build_verifier_sha2_chain(verifier_preprocessing);

    let input = [5u8; 32];

    let prove_start = Instant::now();
    let (output, proof) = prove_sha2_chain(input, config.n);
    let prove_end = Instant::now();
    let prover_duration = prove_end.duration_since(prove_start);

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let mut verifier_durations = Vec::new();

    // For the first verification, we already have the proof
    let verify_start = Instant::now();
    let is_valid = verify_sha2_chain(input, config.n, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();
    verifier_durations.push(verify_end.duration_since(verify_start));

    // For additional iterations, we need to generate new proofs since Jolt consumes them
    for _ in 1..config.verifier_iterations {
        let (verify_output, verify_proof) = prove_sha2_chain(input, config.n);
        assert_eq!(output, verify_output);

        let verify_start = Instant::now();
        let is_valid = verify_sha2_chain(input, config.n, verify_output, verify_proof);
        assert!(is_valid);
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![prover_duration],
        verifier_durations,
        cycle_count: trace_len,
        ..Default::default()
    }
}

fn benchmark_sha3_chain(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = sha3_chain_guest::compile_sha3_chain(target_dir);

    let prover_preprocessing = sha3_chain_guest::preprocess_prover_sha3_chain(&program);
    let verifier_preprocessing = sha3_chain_guest::preprocess_verifier_sha3_chain(&program);

    let prove_sha3_chain = sha3_chain_guest::build_prover_sha3_chain(program, prover_preprocessing);
    let verify_sha3_chain = sha3_chain_guest::build_verifier_sha3_chain(verifier_preprocessing);

    let input = [5u8; 32];

    let start = Instant::now();
    let (output, proof) = prove_sha3_chain(input, config.n);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let mut verifier_durations = Vec::new();

    // For the first verification, we already have the proof
    let verify_start = Instant::now();
    let is_valid = verify_sha3_chain(input, config.n, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();
    verifier_durations.push(verify_end.duration_since(verify_start));

    // For additional iterations, we need to generate new proofs since Jolt consumes them
    for _ in 1..config.verifier_iterations {
        let (verify_output, verify_proof) = prove_sha3_chain(input, config.n);
        assert_eq!(output, verify_output);

        let verify_start = Instant::now();
        let is_valid = verify_sha3_chain(input, config.n, verify_output, verify_proof);
        assert!(is_valid);
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![end.duration_since(start)],
        verifier_durations,
        cycle_count: trace_len,
        ..Default::default()
    }
}

fn benchmark_sha3(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = sha3_guest::compile_sha3(target_dir);

    let prover_preprocessing = sha3_guest::preprocess_prover_sha3(&program);
    let verifier_preprocessing = sha3_guest::preprocess_verifier_sha3(&program);

    let prove_sha3 = sha3_guest::build_prover_sha3(program, prover_preprocessing);
    let verify_sha3 = sha3_guest::build_verifier_sha3(verifier_preprocessing);

    let input = vec![5u8; config.n as usize];
    let input = input.as_slice();

    let start = Instant::now();
    let (output, proof) = prove_sha3(input);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let mut verifier_durations = Vec::new();

    // Serialize proof once for reuse across iterations
    let mut proof_bytes = Vec::new();
    proof
        .serialize_with_mode(&mut proof_bytes, Compress::Yes)
        .unwrap();

    // For the first verification, deserialize and use the proof
    let verify_start = Instant::now();
    let proof_clone =
        JoltHyperKZGProof::deserialize_with_mode(&proof_bytes[..], Compress::Yes, Validate::Yes)
            .unwrap();
    let is_valid = verify_sha3(input, output, proof_clone);
    assert!(is_valid);
    let verify_end = Instant::now();
    verifier_durations.push(verify_end.duration_since(verify_start));

    // For additional iterations, deserialize a fresh proof each time
    for _ in 1..config.verifier_iterations {
        let verify_start = Instant::now();
        let proof_clone = JoltHyperKZGProof::deserialize_with_mode(
            &proof_bytes[..],
            Compress::Yes,
            Validate::Yes,
        )
        .unwrap();
        let is_valid = verify_sha3(input, output, proof_clone);
        assert!(is_valid);
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![end.duration_since(start)],
        verifier_durations,
        cycle_count: trace_len,
        ..Default::default()
    }
}

fn benchmark_sha2(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = sha2_guest::compile_sha2(target_dir);

    let prover_preprocessing = sha2_guest::preprocess_prover_sha2(&program);
    let verifier_preprocessing = sha2_guest::preprocess_verifier_sha2(&program);

    let prove_sha2 = sha2_guest::build_prover_sha2(program, prover_preprocessing);
    let verify_sha2 = sha2_guest::build_verifier_sha2(verifier_preprocessing);

    let input = vec![5u8; config.n as usize];
    let input = input.as_slice();

    let start = Instant::now();
    let (output, proof) = prove_sha2(input);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let mut verifier_durations = Vec::new();

    // Serialize proof once for reuse across iterations
    let mut proof_bytes = Vec::new();
    proof
        .serialize_with_mode(&mut proof_bytes, Compress::Yes)
        .unwrap();

    // For the first verification, deserialize and use the proof
    let verify_start = Instant::now();
    let proof_clone =
        JoltHyperKZGProof::deserialize_with_mode(&proof_bytes[..], Compress::Yes, Validate::Yes)
            .unwrap();
    let is_valid = verify_sha2(input, output, proof_clone);
    assert!(is_valid);
    let verify_end = Instant::now();
    verifier_durations.push(verify_end.duration_since(verify_start));

    // For additional iterations, deserialize a fresh proof each time
    for _ in 1..config.verifier_iterations {
        let verify_start = Instant::now();
        let proof_clone = JoltHyperKZGProof::deserialize_with_mode(
            &proof_bytes[..],
            Compress::Yes,
            Validate::Yes,
        )
        .unwrap();
        let is_valid = verify_sha2(input, output, proof_clone);
        assert!(is_valid);
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![end.duration_since(start)],
        verifier_durations,
        cycle_count: trace_len,
        ..Default::default()
    }
}

fn benchmark_fib(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = fibonacci_guest::compile_fib(target_dir);

    let prover_preprocessing = fibonacci_guest::preprocess_prover_fib(&program);
    let verifier_preprocessing = fibonacci_guest::preprocess_verifier_fib(&program);

    let prove_fib = fibonacci_guest::build_prover_fib(program, prover_preprocessing);
    let verify_fib = fibonacci_guest::build_verifier_fib(verifier_preprocessing);

    let start = Instant::now();
    let (output, proof) = prove_fib(config.n);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let mut verifier_durations = Vec::new();

    // Serialize proof once for reuse across iterations
    let mut proof_bytes = Vec::new();
    proof
        .serialize_with_mode(&mut proof_bytes, Compress::Yes)
        .unwrap();

    // For the first verification, deserialize and use the proof
    let verify_start = Instant::now();
    let proof_clone =
        JoltHyperKZGProof::deserialize_with_mode(&proof_bytes[..], Compress::Yes, Validate::Yes)
            .unwrap();
    let is_valid = verify_fib(config.n, output, proof_clone);
    assert!(is_valid);
    let verify_end = Instant::now();
    verifier_durations.push(verify_end.duration_since(verify_start));

    // For additional iterations, deserialize a fresh proof each time
    for _ in 1..config.verifier_iterations {
        let verify_start = Instant::now();
        let proof_clone = JoltHyperKZGProof::deserialize_with_mode(
            &proof_bytes[..],
            Compress::Yes,
            Validate::Yes,
        )
        .unwrap();
        let is_valid = verify_fib(config.n, output, proof_clone);
        assert!(is_valid);
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![end.duration_since(start)],
        verifier_durations,
        cycle_count: trace_len,
        ..Default::default()
    }
}

fn benchmark_ecadd(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = ec_guest::compile_ecadd(target_dir);

    let prover_preprocessing = ec_guest::preprocess_prover_ecadd(&program);
    let verifier_preprocessing = ec_guest::preprocess_verifier_ecadd(&program);

    let prove_ec = ec_guest::build_prover_ecadd(program, prover_preprocessing);
    let verify_ec = ec_guest::build_verifier_ecadd(verifier_preprocessing);

    let start = Instant::now();
    let (output, proof) = prove_ec(config.n);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let mut verifier_durations = Vec::new();

    // Serialize proof once for reuse across iterations
    let mut proof_bytes = Vec::new();
    proof
        .serialize_with_mode(&mut proof_bytes, Compress::Yes)
        .unwrap();

    // For the first verification, deserialize and use the proof
    let verify_start = Instant::now();
    let proof_clone =
        JoltHyperKZGProof::deserialize_with_mode(&proof_bytes[..], Compress::Yes, Validate::Yes)
            .unwrap();
    let is_valid = verify_ec(config.n, output, proof_clone);
    assert!(is_valid);
    let verify_end = Instant::now();
    verifier_durations.push(verify_end.duration_since(verify_start));

    // For additional iterations, deserialize a fresh proof each time
    for _ in 1..config.verifier_iterations {
        let verify_start = Instant::now();
        let proof_clone = JoltHyperKZGProof::deserialize_with_mode(
            &proof_bytes[..],
            Compress::Yes,
            Validate::Yes,
        )
        .unwrap();
        let is_valid = verify_ec(config.n, output, proof_clone);
        assert!(is_valid);
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![end.duration_since(start)],
        verifier_durations,
        cycle_count: trace_len,
        ..Default::default()
    }
}

fn benchmark_mat_mul(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = mat_mul_guest::compile_matrix_mul(target_dir);

    let prover_preprocessing = mat_mul_guest::preprocess_prover_matrix_mul(&program);
    let verifier_preprocessing = mat_mul_guest::preprocess_verifier_matrix_mul(&program);

    let prove_mat_mul = mat_mul_guest::build_prover_matrix_mul(program, prover_preprocessing);
    let verify_mat_mul = mat_mul_guest::build_verifier_matrix_mul(verifier_preprocessing);

    let start = Instant::now();
    let (output, proof) = prove_mat_mul(config.n as usize);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let mut verifier_durations = Vec::new();

    // Serialize proof once for reuse across iterations
    let mut proof_bytes = Vec::new();
    proof
        .serialize_with_mode(&mut proof_bytes, Compress::Yes)
        .unwrap();

    // For the first verification, deserialize and use the proof
    let verify_start = Instant::now();
    let proof_clone =
        JoltHyperKZGProof::deserialize_with_mode(&proof_bytes[..], Compress::Yes, Validate::Yes)
            .unwrap();
    let is_valid = verify_mat_mul(config.n as usize, output, proof_clone);
    assert!(is_valid);
    let verify_end = Instant::now();
    verifier_durations.push(verify_end.duration_since(verify_start));

    // For additional iterations, deserialize a fresh proof each time
    for _ in 1..config.verifier_iterations {
        let verify_start = Instant::now();
        let proof_clone = JoltHyperKZGProof::deserialize_with_mode(
            &proof_bytes[..],
            Compress::Yes,
            Validate::Yes,
        )
        .unwrap();
        let is_valid = verify_mat_mul(config.n as usize, output, proof_clone);
        assert!(is_valid);
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![end.duration_since(start)],
        verifier_durations,
        cycle_count: trace_len,
        ..Default::default()
    }
}

fn benchmark_blake_chain(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = blake_chain_guest::compile_blake_chain(target_dir);

    let prover_preprocessing = blake_chain_guest::preprocess_prover_blake_chain(&program);
    let verifier_preprocessing = blake_chain_guest::preprocess_verifier_blake_chain(&program);

    let prove_blake_chain = blake_chain_guest::build_prover_blake_chain(program, prover_preprocessing);
    let verify_blake_chain = blake_chain_guest::build_verifier_blake_chain(verifier_preprocessing);

    let input = [5u8; 32];

    let start = Instant::now();
    let (output, proof) = prove_blake_chain(input, config.n);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let mut verifier_durations = Vec::new();

    // For the first verification, we already have the proof
    let verify_start = Instant::now();
    let is_valid = verify_blake_chain(input, config.n, output, proof);
    assert!(is_valid);
    let verify_end = Instant::now();
    verifier_durations.push(verify_end.duration_since(verify_start));

    // For additional iterations, we need to generate new proofs since Jolt consumes them
    for _ in 1..config.verifier_iterations {
        let (verify_output, verify_proof) = prove_blake_chain(input, config.n);
        assert_eq!(output, verify_output);

        let verify_start = Instant::now();
        let is_valid = verify_blake_chain(input, config.n, verify_output, verify_proof);
        assert!(is_valid);
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![end.duration_since(start)],
        verifier_durations,
        cycle_count: trace_len,
        ..Default::default()
    }
}

fn benchmark_blake(config: &BenchmarkConfig) -> BenchmarkResult {
    let target_dir = "/tmp/jolt-guest-targets";
    let program = blake_guest::compile_blake(target_dir);

    let prover_preprocessing = blake_guest::preprocess_prover_blake(&program);
    let verifier_preprocessing = blake_guest::preprocess_verifier_blake(&program);

    let prove_blake = blake_guest::build_prover_blake(program, prover_preprocessing);
    let verify_blake = blake_guest::build_verifier_blake(verifier_preprocessing);

    let input = vec![5u8; config.n as usize];
    let input = input.as_slice();

    let start = Instant::now();
    let (output, proof) = prove_blake(input);
    let end = Instant::now();

    let proof_size = proof.size().unwrap();
    let trace_len = proof.proof.trace_length;

    let mut verifier_durations = Vec::new();

    // Serialize proof once for reuse across iterations
    let mut proof_bytes = Vec::new();
    proof
        .serialize_with_mode(&mut proof_bytes, Compress::Yes)
        .unwrap();

    // For the first verification, deserialize and use the proof
    let verify_start = Instant::now();
    let proof_clone =
        JoltHyperKZGProof::deserialize_with_mode(&proof_bytes[..], Compress::Yes, Validate::Yes)
            .unwrap();
    let is_valid = verify_blake(input, output, proof_clone);
    assert!(is_valid);
    let verify_end = Instant::now();
    verifier_durations.push(verify_end.duration_since(verify_start));

    // For additional iterations, deserialize a fresh proof each time
    for _ in 1..config.verifier_iterations {
        let verify_start = Instant::now();
        let proof_clone = JoltHyperKZGProof::deserialize_with_mode(
            &proof_bytes[..],
            Compress::Yes,
            Validate::Yes,
        )
        .unwrap();
        let is_valid = verify_blake(input, output, proof_clone);
        assert!(is_valid);
        let verify_end = Instant::now();
        verifier_durations.push(verify_end.duration_since(verify_start));
    }

    BenchmarkResult {
        proof_size,
        prover_durations: vec![end.duration_since(start)],
        verifier_durations,
        cycle_count: trace_len,
        ..Default::default()
    }
}
