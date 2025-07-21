use clap::{arg, Parser};
use std::{
    fs,
    process::Command,
};

use utils::{BenchmarkResult, BenchmarkResultWithMetadata, BenchmarkMetadata, BenchmarkConfig, BenchmarkId};

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

    /// Enable memory monitoring (requires running as root with memuse)
    #[arg(long)]
    enable_memory_monitoring: bool,

    /// Arguments to pass to the benchmark binary
    #[arg(trailing_var_arg = true)]
    args: Vec<String>,
}

fn main() {
    let cli = Cli::parse();
    let name = cli.bench_name;
    let root_folder = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).parent().unwrap();
    let bench_arg = cli.bench_arg;

    // Create benchmark_results directory if it doesn't exist
    let results_dir = root_folder.join("benchmark_results");
    fs::create_dir_all(&results_dir).expect("Failed to create benchmark_results directory");

    let memory_file_path = if cli.enable_memory_monitoring {
        let memory_outputs_dir = root_folder.join("memory_outputs");
        fs::create_dir_all(&memory_outputs_dir).expect("Failed to create memory_outputs directory");
        Some(memory_outputs_dir.join(format!("{}_memory.txt", name.replace("-", "_"))))
    } else {
        None
    };

    // Run the benchmark (with or without memory monitoring)
    let benchmark_cmd = format!("{} --n {} --verifier-iterations {} {}", 
                               cli.bin, bench_arg, cli.verifier_iterations, cli.args.join(" "));
    
    if let Some(ref memory_path) = memory_file_path {
        // Run with memuse for memory monitoring
        let memuse_path = root_folder.join("memuse");
        Command::new("sudo")
            .arg(&memuse_path)
            .arg(memory_path)
            .arg("sh")
            .arg("-c")
            .arg(&benchmark_cmd)
            .status()
            .expect("Failed to run benchmark with memory monitoring");
    } else {
        // Run benchmark directly
        Command::new(cli.bin.clone())
            .arg("--n")
            .arg(&bench_arg.to_string())
            .arg("--verifier-iterations")
            .arg(&cli.verifier_iterations.to_string())
            .args(cli.args)
            .status()
            .expect("Failed to run the benchmark");
    }

    // Read the temporary results.json file
    let file_content =
        std::fs::read_to_string("results.json").expect("Failed to read the JSON file");
    let mut result: BenchmarkResult =
        serde_json::from_str(&file_content).expect("Failed to parse JSON");

    // Read memory data if monitoring was enabled
    if let Some(memory_path) = memory_file_path {
        if memory_path.exists() {
            let memory_content = std::fs::read_to_string(&memory_path)
                .expect(&format!("Failed to read memory file: {}", memory_path.display()));
            
            // Extract peak memory from memory file (format: "PEAK <bytes>")
            for line in memory_content.lines() {
                if line.starts_with("PEAK ") {
                    if let Ok(peak_memory) = line.split_whitespace().nth(1).unwrap_or("0").parse::<u64>() {
                        result.peak_memory = Some(peak_memory);
                        println!("Read peak memory: {} bytes", peak_memory);
                    }
                    break;
                }
            }
        }
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
    
    let result_with_metadata = BenchmarkResultWithMetadata {
        metadata,
        result,
    };

    // Save JSON to permanent location
    let json_filename = format!("{}-n{}.json", name, bench_arg);
    let json_path = results_dir.join(json_filename);
    
    let pretty_json = serde_json::to_string_pretty(&result_with_metadata).expect("Failed to serialize JSON");
    fs::write(&json_path, pretty_json).expect("Failed to write JSON file");
    
    println!("Results saved to: {}", json_path.display());

    // Remove temporary json file
    fs::remove_file("results.json").expect("Failed to remove the temporary JSON file");
}