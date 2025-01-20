use serde_json::Value;
use clap::{Parser};
use common::{prove_and_verify, Cli};
use std::fs;
use std::process::Command;

fn main() {
    let cli = Cli::parse();

    run(cli.n, cli.bench_mem);
}


fn run(n: u32, bench_mem: bool) {
    let program_path = "programs/sha256.cairo".to_string();
    let output_path = "programs/sha256.json".to_string();
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

    println!("Computing n_steps ...");

    // Get PIE Output
    let steps_command = "cairo-run --program=programs/sha256.json --cairo_pie_output=get_steps.zip --layout=starknet_with_keccak --program_input=programs/input.json";
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
        println!("n_steps: {:?}", n_steps_value.as_u64());
        n_steps_value.as_u64() 
    } else {
        eprintln!("Field 'n_steps' not found in the JSON file.");
        None
    };

    // prove and verify
    prove_and_verify(command, args.to_vec(), output_file.clone(), n_steps.unwrap());

}
