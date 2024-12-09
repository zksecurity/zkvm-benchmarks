use serde_json::Value;
use std::fs;
use std::process::Command;
use std::time::Duration;
use std::time::Instant;
use utils::benchmark;

fn main() {

    let inputs = [1];
    benchmark(
        run,
        &inputs,
        "../../benchmark_outputs/cairo_keccak.csv",
        "",
    );
}


fn run(n: u32) -> (Duration, usize) {
    let program_path = "programs/cairo_keccak.cairo".to_string();
    let output_path = "programs/cairo_keccak.json".to_string();

    // Compile Cairo code
    let status = Command::new("cairo-compile")
        .arg(&program_path) // Path to the Cairo program
        .arg("--output")
        .arg(&output_path) // Output file path
        .arg("--proof_mode")
        .status();

    match status {
        Ok(status) if status.success() => {
            println!("Compilation successful! Compiled file saved to: {}", output_path);
        }
        Ok(status) => {
            eprintln!("Compilation failed with exit code: {}", status.code().unwrap_or(-1));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-compile: {}", err);
        }
    }
    
    // Prove
    let command = "stone-cli";

    // let program_input = format!("[{}]", n).to_string();
    let program_input = "programs/keccak_input.json";
    let output_file = format!("keccak_proof.json").to_string();
    let args = [
        "prove",
        "--cairo_version",
        "cairo0",
        "--cairo_program",
        &output_path,
        "--layout",
        "starknet-with-keccak",
        "--program_input_file",
        program_input,
        "--output",
        &output_file,
        "--stone_version",
        "v6",
    ];

    prove_and_verify(command, args.to_vec(), output_file.clone())
}


fn prove_and_verify(command: &str, args: Vec<&str>, output_file: String) -> (Duration, usize) {
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

    println!("verify : {:?}", verify_end.duration_since(verify_start));

    (end.duration_since(start), proof_bytes)
}