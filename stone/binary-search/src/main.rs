use clap::{Parser};
use common::{prove_and_verify, Cli, compute_cycle_count};
use std::fs;

fn main() {
    // read args from cli
    let cli = Cli::parse();

    run(cli.n, cli.bench_mem);
}

fn run(n: u32, bench_mem: bool) {
    // get cycle count command
    let program_file = "../../binary-search/programs/binary_search.cairo".to_string();
    let array: Vec<u32> = (1..=n).collect();
    let program_input = format!(
        "[{}]",
        array.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(" ")
    );
    let steps_command = format!("cargo run {} --layout dynamic --cairo_layout_params_file ../../configs/cairo_layout_params_file.json --cairo_pie_output get_steps.zip --args '{}'", program_file, program_input).to_string();

    // compute cycle count
    let steps_dir = "../cairo-vm/cairo1-run".to_string();
    std::env::set_current_dir(&steps_dir).unwrap();
    let cycle_count = compute_cycle_count(&steps_command);

    // prove and verify command
    let command = "stone-cli";
    let program_path = "programs/binary_search.cairo".to_string();
    let output_file = format!("proof_{}.json", n);
    let layout = "automatic".to_string();
    // let parameter_file = match n {
    //     128 => "../configs/parameter_65536_32.json".to_string(),
    //     256 => "../configs/parameter_65536_32.json".to_string(),
    //     512 => "../configs/parameter_65536_32.json".to_string(),
    //     1024 => "../configs/parameter_65536_32.json".to_string(),
    //     2048 => "../configs/parameter_65536_32.json".to_string(),
    //     _ => unreachable!("Unexpected value for n: {}", n),
    // };
    let parameter_file = "../configs/parameter_65536_32.json".to_string();
    let prover_config_file = "../configs/prover_config.json".to_string();
    let args = if bench_mem {
        vec![
            "prove",
            "--cairo_program",
            &program_path,
            "--program_input",
            &program_input,
            "--parameter_file",
            &parameter_file,
            "--prover_config_file",
            &prover_config_file,
            "--layout",
            &layout,
            "--output",
            &output_file,
            "--stone_version",
            "v6",
            "--bench_memory",
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
        ]
    };
    
    // prove and verify
    let prove_dir = "../../binary-search".to_string();
    std::env::set_current_dir(&prove_dir).unwrap();
    let (proof_bytes, duration, verifier_duration) = prove_and_verify(command, args.to_vec(), output_file.clone());

    // save in a json file
    let data_file = "results.json";
    let data_json = format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_bytes, duration.as_millis(), verifier_duration.as_millis(), cycle_count);
    fs::write(data_file, data_json).expect("Failed to write the JSON file");
}

