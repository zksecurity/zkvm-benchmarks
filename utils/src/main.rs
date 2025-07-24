use std::fs;

use clap::{arg, Parser};
use utils::{
    memory, BenchmarkConfig, BenchmarkConfigAndResult, BenchmarkId, BenchmarkName, BenchmarkResult,
    BenchmarkResultWithMemory, BenchmarkStatus,
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

    /// Arguments to pass to the benchmark binary
    #[arg(trailing_var_arg = true)]
    args: Vec<String>,
}

fn main() {
    let cli = Cli::parse();
    let root_folder = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap();
    let bench_arg = cli.bench_arg;

    // Parse benchmark ID from benchmark name
    let name =
        BenchmarkName::parse(&cli.bench_name).expect("Failed to parse benchmark ID from name");

    // Identifier is (vm, program, n)
    let ident = BenchmarkId {
        name: name.clone(),
        n: bench_arg,
    };

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

    // Run the benchmark binary in a seperate cgroup
    let mem_usage = memory::MemoryMonitor::new()
        .run_with_memory_tracking(&cli.bin, &benchmark_args)
        .unwrap();

    // handle benchmark result (success or failure)

    let config = BenchmarkConfig {
        n: bench_arg,
        program: name.program.clone(),
        verifier_iterations: cli.verifier_iterations,
    };

    let result = if mem_usage.result.is_ok() {
        // Benchmark succeeded, read the temporary results.json file
        let file_contents = std::fs::read_to_string("results.json").unwrap();

        // Set peak memory
        let result = BenchmarkResultWithMemory {
            result: serde_json::from_str::<BenchmarkResult>(&file_contents).unwrap(),
            peak_memory: mem_usage.memory,
        };

        // print an overview for debugging
        {
            let prover_times: String = result
                .result
                .prover_durations
                .iter()
                .map(|d| d.as_millis().to_string())
                .collect::<Vec<String>>()
                .join(", ");

            let verifier_times: String = result
                .result
                .verifier_durations
                .iter()
                .map(|d| d.as_millis().to_string())
                .collect::<Vec<String>>()
                .join(", ");

            println!("Results of {}", ident);
            println!("  Proof Size    : {} bytes", result.result.proof_size);
            println!("  Peak Memory   : {} bytes", result.peak_memory);
            println!("  Cycles Count  : {}", result.result.cycle_count);
            println!("  Prover Time   : {} seconds", prover_times);
            println!("  Verifier Time : {} seconds", verifier_times);
        };

        // return successful benchmark result
        BenchmarkConfigAndResult {
            config,
            result: BenchmarkStatus::Success(result),
        }
    } else {
        // print error message
        eprintln!("Benchmark failed with: {:?}", mem_usage.result);
        BenchmarkConfigAndResult {
            config,
            result: BenchmarkStatus::Failure(mem_usage.result),
        }
    };

    // Save JSON to permanent location
    let json_filename = format!("{}.json", ident);
    let json_path = results_dir.join(json_filename);
    fs::write(&json_path, result.to_json()).unwrap();
    println!("Results saved to: {}", json_path.display());

    // Remove temporary json file if it exists
    let _ = fs::remove_file("results.json");
}
