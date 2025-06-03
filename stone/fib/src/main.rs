use clap::{Parser};
use common::{prove_and_verify, Cli, compute_cycle_count};
use std::fs;

fn main() {
    // read args from cli
    let cli = Cli::parse();

    run(cli.n);
}

fn run(n: u32) {
    // get cycle count command
    let program_file = "../../fib/programs/fibonacci.cairo".to_string();
    let program_input = format!("[{}]", n).to_string();
    let steps_command = format!("cargo run {} --layout dynamic --cairo_layout_params_file ../../configs/cairo_layout_params_file.json --cairo_pie_output get_steps.zip --args '{}'", program_file, program_input).to_string();

    // compute cycle count
    let steps_dir = "../cairo-vm/cairo1-run".to_string();
    std::env::set_current_dir(&steps_dir).unwrap();
    let cycle_count = compute_cycle_count(&steps_command);

    // prove and verify command
    let command = "stone-cli";
    let program_path = "programs/fibonacci.cairo".to_string();
    let output_file = format!("proof_{}.json", n);
    let layout = "automatic".to_string();
    let parameter_file = match n {
        4096 => "../configs/parameter_65536_32.json".to_string(),
        8192 => "../configs/parameter_65536_64.json".to_string(),
        16384 => "../configs/parameter_131072.json".to_string(),
        32768 => "../configs/parameter_262144.json".to_string(),
        65536 => "../configs/parameter_524288.json".to_string(),
        131072 => "../configs/parameter_1048576.json".to_string(),
        262144 => "../configs/parameter_2097152.json".to_string(),
        524288 => "../configs/parameter_4194304.json".to_string(),
        _ => unreachable!("Unexpected value for n: {}", n),
    };
    
    let prover_config_file = "../configs/prover_config.json".to_string();
    let args = vec![
        "prove",
        "--cairo_program",
        &program_path,
        "--program_input",
        &program_input,
        "--parameter_file",
        &parameter_file,
        "--prover_config_file",
        &prover_config_file,
        "--output",
        &output_file,
        "--layout",
        &layout,
        "--stone_version",
        "v6",
    ];
    
    // prove and verify
    let prove_dir = "../../fib".to_string();
    std::env::set_current_dir(&prove_dir).unwrap();
    let (proof_bytes, duration, verifier_duration) = prove_and_verify(command, args.to_vec(), output_file.clone());

    // save in a json file
    let data_file = "results.json";
    let data_json = format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_bytes, duration.as_millis(), verifier_duration.as_millis(), cycle_count);
    fs::write(data_file, data_json).expect("Failed to write the JSON file");
}

