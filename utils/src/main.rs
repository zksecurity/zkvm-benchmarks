use clap::{arg, Parser};
use core::str;
use csv::{ReaderBuilder, WriterBuilder};
use serde::{Deserialize, Serialize};
use std::{
    error::Error,
    fs::{self, File},
    io::Write,
    process::Command,
    time::{Duration, Instant},
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

#[derive(Deserialize, Serialize, Debug)]
struct Record {
    n: String,
    #[serde(rename = "time(ms)")]
    time_ms: u64,
    #[serde(rename = "proof size(bytes)")]
    proof_size: u64,
    #[serde(rename = "peak memory")]
    memory: String,
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
                .arg("-o")
                .arg("heaptrack-prover")
                .arg(cli.bin)
                .arg("--n")
                .arg(&bench_arg)
                .args(cli.args)
                .status()
                .expect("Failed to run the benchmark under heaptrack");
        }

        // parse peak heap memory usage from heaptrack file
        // Analyze the heaptrack results
        let output = Command::new("heaptrack")
            .arg("-a")
            .arg("heaptrack-prover.zst") // Ensure the filename matches what heaptrack produced
            .output()
            .expect("Failed to analyze the heaptrack results");

        let stdout = str::from_utf8(&output.stdout).expect("Invalid UTF-8 in heaptrack output");

        // Look for the line that contains "peak heap memory consumption:"
        let peak_line = stdout
            .lines()
            .find(|line| line.contains("peak heap memory consumption"))
            .expect("No 'peak heap memory consumption' line found in heaptrack output");

        // peak_line looks like: "peak heap memory consumption: 1.35G"
        // We can split by ':' and trim the second part
        let peak_value_str = peak_line
            .split(':')
            .nth(1)
            .expect("Failed to split peak consumption line")
            .trim();

        update_or_insert_record(
            &file,
            &bench_arg,
            None,
            None,
            Some(peak_value_str.to_string()),
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
            .expect("Failed to get duration")
            .as_u64()
            .expect("Failed to convert duration to u64");

        update_or_insert_record(&file, &bench_arg, Some(duration), Some(proof_size), None)
            .expect("Failed to update or insert record");
    }
}

fn update_or_insert_record(
    file_path: &str,
    bench_arg: &str,
    duration: Option<u64>,
    proof_size: Option<u64>,
    memory: Option<String>,
) -> Result<(), Box<dyn Error>> {
    let file_exists = fs::metadata(file_path).is_ok();
    let mut records = Vec::new();

    // Read existing records if file exists
    if file_exists {
        let mut rdr = ReaderBuilder::new()
            .has_headers(true)
            .from_path(file_path)?;
        for result in rdr.deserialize::<Record>() {
            let record = result?;
            records.push(record);
        }
    }

    // Check and update existing record
    let mut updated = false;
    for record in &mut records {
        if record.n == bench_arg {
            if let Some(duration) = duration {
                record.time_ms = duration;
            }
            if let Some(proof_size) = proof_size {
                record.proof_size = proof_size;
            }
            if let Some(ref memory_str) = memory {
                record.memory = memory_str.clone();
            }
            updated = true;
            break;
        }
    }

    // If not found, append a new record
    if !updated {
        let duration = duration.unwrap_or(0);
        let proof_size = proof_size.unwrap_or(0);
        let memory = memory.unwrap_or(0.to_string());
        records.push(Record {
            n: bench_arg.to_string(),
            time_ms: duration,
            proof_size,
            memory,
        });
    }

    // Write all records back
    let mut wtr = WriterBuilder::new()
        .has_headers(true)
        .from_path(file_path)?;
    for record in records {
        wtr.serialize(record)?;
    }
    wtr.flush()?;

    Ok(())
}
