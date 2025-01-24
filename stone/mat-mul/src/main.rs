use clap::{Parser};
use common::{prove_and_verify, Cli};
use std::fs;
use std::process::Command;
use serde_json::Value;

fn main() {
    // read args from cli
    let cli = Cli::parse();

    run(cli.n, cli.bench_mem);
}

fn run(n: u32, bench_mem: bool) {
    // Prove
    let command = "stone-cli";
    let program_path = "programs/mat.cairo".to_string();
    let program_input = format!("[{}]", n).to_string();
    let output_file = format!("proof_{}.json", n);
    let layout = "recursive".to_string();
    let args = if bench_mem {
        vec![
            "prove",
            "--cairo_program",
            &program_path,
            "--program_input",
            &program_input,
            "--output",
            &output_file,
            "--layout",
            &layout,
            "--stone_version",
            "v6",
            "--bench-memory",
            "true",
        ]
    }
    else {
        vec![
            "prove",
            "--cairo_program",
            &program_path,
            "--program_input",
            &program_input,
            "--output",
            &output_file,
            "--layout",
            &layout,
            "--stone_version",
            "v6",
        ]
    };

    println!("Computing n_steps ...");
    // Change Dir
    let steps_dir = "../cairo-vm/cairo1-run".to_string();
    std::env::set_current_dir(&steps_dir).unwrap();

    // Get PIE Output
    let steps_command = format!("cargo run ../../mat-mul/programs/mat.cairo --layout={} --cairo_pie_output get_steps.zip --args '{}'", layout, program_input).to_string();
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

    // Change dir
    let prove_dir = "../../mat-mul".to_string();
    std::env::set_current_dir(&prove_dir).unwrap();
    prove_and_verify(command, args.to_vec(), output_file.clone(), n_steps.unwrap());
}

