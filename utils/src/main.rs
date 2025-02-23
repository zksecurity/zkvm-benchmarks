use clap::{arg, Parser};
use core::str;
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

    /// Run the benchmark under heaptrack for memory profiling
    #[arg(long)]
    bench_mem: bool,

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

    // Build the project in release mode
    Command::new("cargo")
        .arg("build")
        .arg("--release")
        .status()
        .expect("Failed to build the program binary");

    if cli.bench_mem {
        if name.contains("stone") {
            // if it is stone library
            Command::new(cli.bin)
                .arg("--n")
                .arg(&bench_arg)
                .arg("--bench-mem")
                .status()
                .expect("Failed to run the benchmark under heaptrack");
        } else {
            // if it is not stone library
            Command::new("heaptrack")
                .arg("--output") // Explicitly specify the output file
                .arg(format!("{}-{}", name, bench_arg))
                .arg(cli.bin) // The binary to profile
                .arg("--n") // Pass the arguments to the binary
                .arg(&bench_arg) // First argument to the binary
                .args(&cli.args) // Additional arguments
                .env("HEAPTRACK_NO_GUI", "1") // Suppress automatic GUI launch
                .status()
                .expect("Failed to run the benchmark under heaptrack");
        }


        // Determine the correct `.zst` file to analyze
        let zst_file = if name.contains("stone") {
            "heaptrack-prover.zst".to_string()
        } else {
            format!("{}-{}.zst", name, bench_arg)
        };

        // Analyze the `.zst` file using `heaptrack_print`
        let output = Command::new("heaptrack_print")
            .arg(&zst_file)
            .output()
            .expect("Failed to analyze the heaptrack results");

        // Check if the command executed successfully
        if !output.status.success() {
            eprintln!(
                "Heaptrack analysis failed:\n{}",
                String::from_utf8_lossy(&output.stderr)
            );
            panic!("Failed to analyze heaptrack results.");
        }

        // Parse the stdout to find peak heap memory consumption
        let stdout = str::from_utf8(&output.stdout).expect("Invalid UTF-8 in heaptrack output");

        // Look for the line containing "peak heap memory consumption:"
        let peak_line = stdout
            .lines()
            .find(|line| line.contains("peak heap memory consumption"))
            .expect("No 'peak heap memory consumption' line found in heaptrack output");

        // Extract the value after the colon and trim it
        let peak_value_str = peak_line
            .split(':')
            .nth(1)
            .expect("Failed to split peak consumption line")
            .trim();

        let peak_value_num = peak_value_str
            .split('G')
            .next()
            .expect("Failed to split at 'G'")
            .trim();

        update_or_insert_record(
            &file,
            &bench_arg,
            None,
            None,
            None,
            None,
            Some(peak_value_num.to_string()),
        )
        .expect("Failed to update or insert record");
    } else {
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
}