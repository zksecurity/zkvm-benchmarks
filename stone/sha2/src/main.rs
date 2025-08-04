use clap::{Parser};
use common::{bench, Cli};
use std::fs;
use utils::{BenchmarkConfig, BenchmarkResult};

fn main() {
    let cli = Cli::parse();

    let config = BenchmarkConfig {
        n: cli.n,
        program: cli.program.clone(),
        verifier_iterations: cli.verifier_iterations,
    };

    let result = run(config);
    std::fs::write("results.json", result.to_json()).unwrap();
}


fn run(config: BenchmarkConfig) -> BenchmarkResult {
    let program_path = "programs/sha256.cairo".to_string();
    let input = format!("{{\"iterations\": {}}}", config.n);
    let program_input = "programs/input.json";
    fs::write(program_input, input).expect("Failed to write input file");
    let parameter_file = match config.n {
        32 | 64 | 128 | 256 => "../configs/parameter_65536_32.json".to_string(),
        512 => "../configs/parameter_65536_64.json".to_string(),
        1024 => "../configs/parameter_131072.json".to_string(),
        2048 => "../configs/parameter_131072.json".to_string(),
        4096 => "../configs/parameter_262144.json".to_string(),
        8192 => "../configs/parameter_524288.json".to_string(),
        16384 => "../configs/parameter_1048576.json".to_string(),
        // 32768 => "../configs/parameter_2097152.json".to_string(),
        _ => unreachable!("Unexpected value for n: {}", config.n),
    };


    bench(config, &program_path, program_input, &parameter_file)
}
