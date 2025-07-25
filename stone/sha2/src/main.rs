use clap::{Parser};
use common::{prove_and_verify, Cli, compute_cycle_count};
use std::fs;
use std::process::Command;

fn main() {
    let cli = Cli::parse();

    run(cli.n);
}


fn run(n: u32) {
    let program_path = "programs/sha256.cairo".to_string();
    let output_path = "programs/sha256.json".to_string();
    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "programs/input.json";
    fs::write(program_input, input).expect("Failed to write input file");
    let parameter_file = match n {
        32 | 64 | 128 | 256 => "../configs/parameter_65536_32.json".to_string(),
        512 => "../configs/parameter_65536_64.json".to_string(),
        1024 => "../configs/parameter_131072.json".to_string(),
        2048 => "../configs/parameter_131072.json".to_string(),
        4096 => "../configs/parameter_262144.json".to_string(),
        8192 => "../configs/parameter_524288.json".to_string(),
        16384 => "../configs/parameter_1048576.json".to_string(),
        // 32768 => "../configs/parameter_2097152.json".to_string(),
        _ => unreachable!("Unexpected value for n: {}", n),
    };


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

    // compute cycle count
    let steps_command = format!("cairo-run --program={} --cairo_layout_params_file=../configs/cairo_layout_params_file.json --cairo_pie_output=get_steps.zip --layout=dynamic --program_input={}", output_path, program_input);
    let cycle_count = compute_cycle_count(&steps_command);
    println!("run command: {:?}", steps_command);
    
    // prove and verify command
    let command = "stone-cli";

    let output_file = format!("proof_{}.json", n);
    let layout = "automatic".to_string();
    let prover_config_file = "../configs/prover_config.json".to_string();

    let args = vec![
        "prove",
        "--cairo_version",
        "cairo0",
        "--cairo_program",
        &output_path,
        "--layout",
        &layout,
        "--program_input_file",
        program_input,
        "--output",
        &output_file,
        "--parameter_file",
        &parameter_file,
        "--prover_config_file",
        &prover_config_file,
        "--stone_version",
        "v6",
    ];

    // prove and verify
    let (proof_bytes, duration, verifier_duration) = prove_and_verify(command, args.to_vec(), output_file.clone());
    
    // save in a json file
    let data_file = "results.json";
    let data_json = format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_bytes, duration.as_millis(), verifier_duration.as_millis(), cycle_count);
    fs::write(data_file, data_json).expect("Failed to write the JSON file");

}
