
use clap::{Parser};
use common::{prove_and_verify, Cli};
use std::fs;
use std::process::Command;

fn main() {
    let cli = Cli::parse();

    run(cli.n, cli.bench_mem);
}


fn run(n: u32, bench_mem: bool) {
    let program_path = "programs/sha256_chain.cairo".to_string();
    let output_path = "programs/sha256_chain.json".to_string();
    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "programs/input.json";
    fs::write(program_input, input).expect("Failed to write input file");


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

    let output_file = format!("keccak_proof_{}.json", n).to_string();
    let args = if bench_mem {
        vec![
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
            "--bench-memory",
            "true",
        ]
    }
    else {
        vec![
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
        ]
    };

    prove_and_verify(command, args.to_vec(), output_file.clone());
}
