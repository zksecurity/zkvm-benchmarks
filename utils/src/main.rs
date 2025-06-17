use clap::{arg, Parser};
use std::{
    fs,
    process::Command,
};

use utils::update_or_insert_record;

/// A tool to build and optionally benchmark a cargo project
#[derive(Parser, Debug)]
#[clap()]
struct Cli {
    /// The name of executable to run
    /// It is assumed to be located under the target/release directory
    #[arg(long)]
    bin: String,

    /// The benchmark argument to pass to the binary
    #[arg(long)]
    bench_arg: String,

    /// Name of the benchmark
    #[arg(long)]
    bench_name: String,

    /// Arguments to pass to the benchmark binary
    #[arg(trailing_var_arg = true)]
    args: Vec<String>,
}

fn main() {
    let cli = Cli::parse();
    let name = cli.bench_name;
    let root_folder = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).parent().unwrap();
    let file = format!("{}/benchmark_outputs/{}.csv", root_folder.display(), name);
    let bench_arg = cli.bench_arg;

    Command::new(cli.bin.clone())
            .arg("--n")
            .arg(&bench_arg)
            .args(cli.args)
            .status()
            .expect("Failed to run the benchmark");

    // read the proof size from the output file
    let file_content =
        std::fs::read_to_string("results.json").expect("Failed to read the JSON file");
    // read the proof_size
    let json: serde_json::Value =
        serde_json::from_str(&file_content).expect("Failed to parse JSON");
    let proof_size = json
        .get("proof_size")
        .expect("Failed to get proof size")
        .as_u64()
        .expect("Failed to convert proof size to u64");

    let duration = json
        .get("duration")
        .expect("Failed to get prover time")
        .as_u64()
        .expect("Failed to convert duration to u64");

    let verifier_duration = json
        .get("verifier_duration")
        .expect("Failed to get verifier time")
        .as_u64()
        .expect("Failed to convert duration to u64");

    let cycle_count = json
        .get("cycle_count")
        .expect("Failed to get cycle count")
        .as_u64()
        .expect("Failed to convert duration to u64");

    update_or_insert_record(&file, &bench_arg, Some(duration), Some(proof_size), Some(verifier_duration), Some(cycle_count), None)
        .expect("Failed to update or insert record");

    // remove json file
    fs::remove_file("results.json").expect("Failed to remove the JSON file");
}