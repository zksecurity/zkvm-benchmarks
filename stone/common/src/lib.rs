use std::fs;
use std::time::Instant;
use serde_json::Value;
use std::process::Command;
use clap::{arg, Parser};

/// A tool to build and optionally benchmark a cargo project
#[derive(Parser, Debug)]
#[clap()]
pub struct Cli {
    #[arg(long)]
    pub n: u32,
    
    /// Run the benchmark under heaptrack for memory profiling
    #[arg(long)]
    pub bench_mem: bool,
}

pub fn prove_and_verify(command: &str, args: Vec<&str>, output_file: String, n_steps: u64) {
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

    let file_content = fs::read_to_string(file_path).expect("Failed to read the JSON file");

    let json: Value = serde_json::from_str(&file_content).expect("Failed to parse JSON");

    let mut proof_bytes = 0;
    if let Some(proof_hex) = json.get("proof_hex").and_then(|v| v.as_str()) {
        proof_bytes = (proof_hex.len() - 2) / 2;
    } else {
        println!("The 'proof_hex' field is not present or not a string.");
    }

    // Verify
    let verify_command = "stone-cli";
    let verify_args = ["verify", "--proof", &output_file];

    println!(
        "Running Verify command: {} {}",
        verify_command,
        verify_args.join(" ")
    );

    let verify_start = Instant::now();

    let verify_output = Command::new(verify_command)
        .args(verify_args)
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

    let duration = end.duration_since(start);
    let verifier_duration = verify_end.duration_since(verify_start);
    let cycle_count = n_steps;
    // save proof size in a json file
    let proof_size_file = "results.json";
    let proof_size_json = format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_bytes, duration.as_millis(), verifier_duration.as_millis(), cycle_count);
    fs::write(proof_size_file, proof_size_json).expect("Failed to write the JSON file");
}