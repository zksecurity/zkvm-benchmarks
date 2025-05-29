use std::fs;
use std::time::Instant;
use serde_json::Value;
use std::process::Command;
use std::time::Duration;
use clap::{arg, Parser};
use std::env;

/// A tool to build and optionally benchmark a cargo project
#[derive(Parser, Debug)]
#[clap()]
pub struct Cli {
    #[arg(long)]
    pub n: u32,
}

pub fn prove_and_verify(command: &str, args: Vec<&str>, output_file: String) -> (usize, Duration, Duration)  {
    println!("Running Prove command: {} {}", command, args.join(" "));

    let start = Instant::now();

    let sharp_client_cert = env::var("SHARP_CLIENT_CERT").expect("Missing SHARP_CLIENT_CERT");
    let sharp_key_path = env::var("SHARP_KEY_PATH").expect("Missing SHARP_KEY_PATH");
    let output = Command::new(command)
        .args(&args)
        .env("SHARP_CLIENT_CERT", &sharp_client_cert)
        .env("SHARP_KEY_PATH", &sharp_key_path)
        .env("RUST_MIN_STACK", "104857600")
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
    (proof_bytes, duration, verifier_duration)
}

pub fn compute_cycle_count(steps_command: &str) -> u64 {
    println!("Computing n_steps ...");

    let output = Command::new("sh")
        .arg("-c")
        .arg(steps_command)
        .output().unwrap();
    if !output.status.success() {
        eprintln!(
            "Error running steps_command: {}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    // Unzip PIE Output
    let unzip_command = "unzip -o get_steps.zip -d .";
    let unzip_output = Command::new("sh")
        .arg("-c")
        .arg(unzip_command)
        .output().unwrap();
    if !unzip_output.status.success() {
        eprintln!(
            "Error running unzip_command: {}",
            String::from_utf8_lossy(&unzip_output.stderr)
        );
    }

    // Get n_steps from unzipped file
    let json_file = "execution_resources.json";
    let json_content = fs::read_to_string(json_file).unwrap();
    let json_value: Value = serde_json::from_str(&json_content).unwrap();
    let n_steps = if let Some(n_steps_value) = json_value.get("n_steps") {
        println!("n_steps: {:?}", n_steps_value.as_u64().unwrap());
        n_steps_value.as_u64() 
    } else {
        eprintln!("Field 'n_steps' not found in the JSON file.");
        None
    };

    n_steps.unwrap()
}