use std::process::Command;
use std::time::Duration;
use std::time::Instant;
use utils::benchmark;
use serde_json::Value;
use std::fs;

fn main() {
    // fibonacci
    // let ns = [100, 1000, 10000, 50000];
    let ns = [50];
    benchmark(
        benchmark_fib,
        &ns,
        "../benchmark_outputs/fibonacci_stone.csv",
        "n",
    );
}

fn benchmark_fib(n: u32) -> (Duration, usize) {

    // Prove
    let command = "stone-cli";
    let program_path = "programs/fibonacci.cairo".to_string();
    let program_input = format!("[1 {}]", n).to_string();
    let output_file = format!("fibonacci_{}_proof.json", n).to_string();
    let args = [
        "prove",
        "--cairo_program",
        &program_path,
        "--program_input",
        &program_input,
        "--output",
        &output_file,
        "--stone_version",
        "v6",
    ];

    println!("Running Prove command: {} {}", command, args.join(" "));

    let start = Instant::now();

    let output = Command::new(command)
        .args(&args)
        .output()
        .expect("Failed to execute the Prove command");

    let end = Instant::now();

    if output.status.success() {
        println!("Prove Command completed successfully.");
        println!(
            "Standard Output:\n{}",
            String::from_utf8_lossy(&output.stdout)
        );
    } else {
        println!("Prove Command failed with exit code: {}", output.status);
        println!(
            "Standard Error:\n{}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    // Proof Size
    let file_path = &output_file;

    let file_content = fs::read_to_string(file_path)
        .expect("Failed to read the JSON file");

    let json: Value = serde_json::from_str(&file_content)
        .expect("Failed to parse JSON");

    let mut proof_bytes = 0;
    if let Some(proof_hex) = json.get("proof_hex").and_then(|v| v.as_str()) {
        proof_bytes = (proof_hex.len() - 2) / 2;
    } else {
        println!("The 'proof_hex' field is not present or not a string.");
    }

    // Verify
    let verify_command = "stone-cli";
    let verify_args = [
        "verify",
        "--proof",
        &output_file,
    ];

    println!("Running Verify command: {} {}", verify_command, verify_args.join(" "));

    let verify_start = Instant::now();

    let verify_output = Command::new(verify_command)
        .args(&verify_args)
        .output()
        .expect("Failed to execute the Verify command");

    let verify_end = Instant::now();

    if verify_output.status.success() {
        println!("Verify Command completed successfully.");
        println!(
            "Standard Output:\n{}",
            String::from_utf8_lossy(&output.stdout)
        );
    } else {
        println!("Verify Command failed with exit code: {}", output.status);
        println!(
            "Standard Error:\n{}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    println!("verify : {:?}", verify_end.duration_since(verify_start));

    (end.duration_since(start), proof_bytes)
}
