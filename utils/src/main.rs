use clap::{arg, Parser};
use std::{fs, process::Command};

use utils::memory::run_command_with_memory_tracking;
use utils::{
    BenchmarkConfig, BenchmarkId, BenchmarkMetadata, BenchmarkResult, BenchmarkResultWithMetadata,
};

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
    bench_arg: u32,

    /// Name of the benchmark
    #[arg(long)]
    bench_name: String,

    /// Number of verifier iterations to run (default: 1)
    #[arg(long, default_value = "1")]
    verifier_iterations: u32,

    /// Enable memory monitoring (requires running as root)
    #[arg(long)]
    enable_memory_monitoring: bool,

    /// Arguments to pass to the benchmark binary
    #[arg(trailing_var_arg = true)]
    args: Vec<String>,
}

fn main() {
    let cli = Cli::parse();
    let name = cli.bench_name;
    let root_folder = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap();
    let bench_arg = cli.bench_arg;

    // Create benchmark_results directory if it doesn't exist
    let results_dir = root_folder.join("benchmark_results");
    fs::create_dir_all(&results_dir).expect("Failed to create benchmark_results directory");

    // Prepare benchmark arguments
    let mut benchmark_args = vec![
        "--n".to_string(),
        bench_arg.to_string(),
        "--verifier-iterations".to_string(),
        cli.verifier_iterations.to_string(),
    ];
    benchmark_args.extend(cli.args);

    // Run the benchmark (with or without memory monitoring)
    let peak_memory = if cli.enable_memory_monitoring {
        let (status, memory) = run_command_with_memory_tracking(&cli.bin, &benchmark_args)
            .expect("Failed to run benchmark with memory monitoring");

        if !status.success() {
            eprintln!("Benchmark failed with exit code: {:?}", status.code());
            std::process::exit(1);
        }

        Some(memory)
    } else {
        // Run benchmark directly without memory monitoring
        let status = Command::new(&cli.bin)
            .args(&benchmark_args)
            .status()
            .expect("Failed to run the benchmark");

        if !status.success() {
            eprintln!("Benchmark failed with exit code: {:?}", status.code());
            std::process::exit(1);
        }

        None
    };

    // Read the temporary results.json file
    let file_content =
        std::fs::read_to_string("results.json").expect("Failed to read the JSON file");
    let mut result: BenchmarkResult =
        serde_json::from_str(&file_content).expect("Failed to parse JSON");

    // Set peak memory if monitoring was enabled
    if let Some(memory) = peak_memory {
        result.peak_memory = Some(memory);
        println!("Peak memory: {} bytes", memory);
    }

    // Parse benchmark ID from benchmark name
    let id = BenchmarkId::parse(&name).expect("Failed to parse benchmark ID from name");

    // Create result with metadata
    let config = BenchmarkConfig {
        n: bench_arg,
        program: id.program.clone(),
        verifier_iterations: cli.verifier_iterations,
    };

    let metadata = BenchmarkMetadata {
        id,
        benchmark_name: name.clone(),
        config,
    };

    let result_with_metadata = BenchmarkResultWithMetadata { metadata, result };

    // Save JSON to permanent location
    let json_filename = format!("{}-n{}.json", name, bench_arg);
    let json_path = results_dir.join(json_filename);

    let pretty_json =
        serde_json::to_string_pretty(&result_with_metadata).expect("Failed to serialize JSON");
    fs::write(&json_path, pretty_json).expect("Failed to write JSON file");

    println!("Results saved to: {}", json_path.display());

    // Remove temporary json file
    fs::remove_file("results.json").expect("Failed to remove the temporary JSON file");
}
