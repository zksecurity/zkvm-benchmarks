use clap::Parser;
use std::process::Command;
use std::io::Write;
use std::fs;
use std::time::Duration;
pub mod util;
use util::prove_and_verify;

/// A tool to build and optionally benchmark a cargo project
#[derive(Parser, Debug)]
#[clap()]
pub struct Cli {
    #[arg(long)]
    pub n: u32,
    
    /// Run the benchmark under heaptrack for memory profiling
    #[arg(long)]
    pub program: String,
}


fn main() {

    let cli = Cli::parse();

    let (duration, proof_size, verifier_duration, cycle_count) = match cli.program.as_str() {
        "fib" => {
            bench_fibonacci(cli.n)
        },
        "sha2" => {
            bench_sha2(cli.n)
        },
        "sha3" => {
            bench_sha3(cli.n)
        },
        "sha3-chain" => {
            bench_sha3_chain(cli.n)
        },
        "sha2-chain" => {
            bench_sha2_chain(cli.n)
        },
        "mat-mul" => {
            bench_mat_mul(cli.n)
        },
        "ec" => {
            bench_ec(cli.n)
        },
        "blake" => {
            bench_blake(cli.n)
        },
        "blake-chain" => {
            bench_blake_chain(cli.n)
        },
        _ => unreachable!()

    };
    
    let mut file = std::fs::File::create("results.json").unwrap();
    file.write_all(format!("{{\"proof_size\": {}, \"duration\": {}, \"verifier_duration\": {}, \"cycle_count\": {}}}", proof_size, duration.as_millis(), verifier_duration.as_millis(), cycle_count).as_bytes()).unwrap();

}

// fn bench_fibonacci(n: u32) -> (Duration, usize, Duration, usize) {
//     let program_input = format!("[{}]", n);

//     let current_dir = std::env::current_dir().unwrap();
//     let stone_dir = current_dir.join("../stone");
//     let stwo_dir = current_dir;

//     // Generate prover input files with absolute paths
//     let program_file = stone_dir.join("fib/programs/fibonacci.cairo");
//     let public_input = stwo_dir.join("fib/public_input.json");
//     let private_input = stwo_dir.join("fib/private_input.json");
//     let trace = stwo_dir.join("fib/trace.bin");
//     let memory = stwo_dir.join("fib/memory.bin");
//     let layout_params = stone_dir.join("configs/cairo_layout_params_file.json");

//     // Run command with explicit working directory
//     let cairo_vm_dir = stone_dir.join("cairo-vm/cairo1-run");
//     let status = Command::new("cargo")
//         .arg("run")
//         .arg(program_file)
//         .arg("--layout").arg("all_cairo_stwo")
//         // .arg("--cairo_layout_params_file").arg(layout_params)
//         .arg("--args").arg(program_input)
//         .arg("--air_public_input").arg(&public_input)
//         .arg("--air_private_input").arg(&private_input)
//         .arg("--trace_file").arg(&trace)
//         .arg("--memory_file").arg(&memory)
//         .arg("--proof_mode")
//         .current_dir(cairo_vm_dir)
//         .status()
//         .expect("Failed to run command");

//     if !status.success() {
//         eprintln!("Command failed with status: {:?}", status);
//     }

//     // No need to change directories - use absolute paths
//     prove_and_verify(
//         public_input.to_string_lossy().to_string(),
//         private_input.to_string_lossy().to_string()
//     )
// }

fn bench_mat_mul(n: u32) -> (Duration, usize, Duration, usize) {

    let program_input = format!("[{}]", n);

    let current_dir = std::env::current_dir().unwrap();
    let stone_dir = current_dir.join("../stone");
    let stwo_dir = current_dir;

    // Generate prover input files with absolute paths
    let program_file = stone_dir.join("mat-mul/programs/mat.cairo");
    let public_input = stwo_dir.join("mat_mul/public_input.json");
    let private_input = stwo_dir.join("mat_mul/private_input.json");
    let trace = stwo_dir.join("mat_mul/trace.bin");
    let memory = stwo_dir.join("mat_mul/memory.bin");
    let layout_params = stone_dir.join("configs/cairo_layout_params_file.json");

    // Run command with explicit working directory
    let cairo_vm_dir = stone_dir.join("cairo-vm/cairo1-run");
    let status = Command::new("cargo")
        .arg("run")
        .arg(program_file)
        .arg("--layout").arg("dynamic")
        .arg("--cairo_layout_params_file").arg(layout_params)
        .arg("--args").arg(program_input)
        .arg("--air_public_input").arg(&public_input)
        .arg("--air_private_input").arg(&private_input)
        .arg("--trace_file").arg(&trace)
        .arg("--memory_file").arg(&memory)
        .arg("--proof_mode")
        .current_dir(cairo_vm_dir)
        .status()
        .expect("Failed to run command");

    if !status.success() {
        eprintln!("Command failed with status: {:?}", status);
    }

    // No need to change directories - use absolute paths
    prove_and_verify(
        public_input.to_string_lossy().to_string(),
        private_input.to_string_lossy().to_string()
    )
}

fn bench_fibonacci(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./fib/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "../stone/fib/programs/fibonacci.cairo".to_string();
    let output_path = "./fib/fib.json".to_string();

    let public_input = "./fib/public_input.json".to_string();
    let private_input = "./fib/private_input.json".to_string();
    let trace = "./fib/trace.bin".to_string();
    let memory = "./fib/memory.bin".to_string();

    println!("Generating Prover Input Files...");
    let status = Command::new("cairo-compile")
        .arg(&program_path)
        .arg("--output")
        .arg(&output_path)
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

    let run_command = format!(
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        output_path, program_input, public_input, private_input, trace, memory,
    );
    println!("cairo-run: {:?}", run_command);
    let output = Command::new("sh")
        .arg("-c")
        .arg(run_command)
        .output();
    match output {
        Ok(output) if output.status.success() => {
            println!("cairo-run successful!");
            println!("stdout: {}", String::from_utf8_lossy(&output.stdout));
        }
        Ok(output) => {
            eprintln!(
                "cairo-run failed with exit code: {}",
                output.status.code().unwrap_or(-1)
            );
            eprintln!("stderr: {}", String::from_utf8_lossy(&output.stderr));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-run: {}", err);
        }
    }

    prove_and_verify(public_input, private_input)
}

fn bench_sha2(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha2/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "../stone/sha2/programs/sha256.cairo".to_string();
    let output_path = "./sha2/sha2.json".to_string();

    let public_input = "./sha2/public_input.json".to_string();
    let private_input = "./sha2/private_input.json".to_string();
    let trace = "./sha2/trace.bin".to_string();
    let memory = "./sha2/memory.bin".to_string();

    println!("Generating Prover Input Files...");
    let status = Command::new("cairo-compile")
        .arg(&program_path)
        .arg("--output")
        .arg(&output_path)
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

    let run_command = format!(
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        output_path, program_input, public_input, private_input, trace, memory,
    );
    println!("cairo-run: {:?}", run_command);
    let output = Command::new("sh")
        .arg("-c")
        .arg(run_command)
        .output();
    match output {
        Ok(output) if output.status.success() => {
            println!("cairo-run successful!");
            println!("stdout: {}", String::from_utf8_lossy(&output.stdout));
        }
        Ok(output) => {
            eprintln!(
                "cairo-run failed with exit code: {}",
                output.status.code().unwrap_or(-1)
            );
            eprintln!("stderr: {}", String::from_utf8_lossy(&output.stderr));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-run: {}", err);
        }
    }

    prove_and_verify(public_input, private_input)
}

fn bench_sha2_chain(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha2-chain/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "../stone/sha2-chain/programs/sha256_chain.cairo".to_string();
    let output_path = "./sha2-chain/sha2_chain.json".to_string();

    let public_input = "./sha2-chain/public_input.json".to_string();
    let private_input = "./sha2-chain/private_input.json".to_string();
    let trace = "./sha2-chain/trace.bin".to_string();
    let memory = "./sha2-chain/memory.bin".to_string();

    println!("Generating Prover Input Files...");
    let status = Command::new("cairo-compile")
        .arg(&program_path)
        .arg("--output")
        .arg(&output_path)
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

    let run_command = format!(
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        output_path, program_input, public_input, private_input, trace, memory,
    );
    println!("cairo-run: {:?}", run_command);
    let output = Command::new("sh")
        .arg("-c")
        .arg(run_command)
        .output();
    match output {
        Ok(output) if output.status.success() => {
            println!("cairo-run successful!");
            println!("stdout: {}", String::from_utf8_lossy(&output.stdout));
        }
        Ok(output) => {
            eprintln!(
                "cairo-run failed with exit code: {}",
                output.status.code().unwrap_or(-1)
            );
            eprintln!("stderr: {}", String::from_utf8_lossy(&output.stderr));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-run: {}", err);
        }
    }

    prove_and_verify(public_input, private_input)
}


fn bench_sha3(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha3/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    // let program_path = "../stone/sha3-builtin/programs/keccak.cairo".to_string();
    let program_path = "../stone/sha3/programs/cairo_keccak.cairo".to_string();
    let output_path = "./sha3/sha3.json".to_string();

    let public_input = "./sha3/public_input.json".to_string();
    let private_input = "./sha3/private_input.json".to_string();
    let trace = "./sha3/trace.bin".to_string();
    let memory = "./sha3/memory.bin".to_string();

    println!("Generating Prover Input Files...");
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

    let run_command = format!(
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        output_path, program_input, public_input, private_input, trace, memory,
    );
    println!("cairo-run: {:?}", run_command);
    let output = Command::new("sh")
        .arg("-c")
        .arg(run_command)
        .output();
    match output {
        Ok(output) if output.status.success() => {
            println!("cairo-run successful!");
            println!("stdout: {}", String::from_utf8_lossy(&output.stdout));
        }
        Ok(output) => {
            eprintln!(
                "cairo-run failed with exit code: {}",
                output.status.code().unwrap_or(-1)
            );
            eprintln!("stderr: {}", String::from_utf8_lossy(&output.stderr));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-run: {}", err);
        }
    }

    prove_and_verify(public_input, private_input)
}

fn bench_sha3_chain(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./sha3-chain/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    // let program_path = "../stone/sha3-chain-builtin/programs/keccak.cairo".to_string();
    let program_path = "../stone/sha3-chain/programs/keccak_chain.cairo".to_string();
    let output_path = "./sha3-chain/sha3_chain.json".to_string();

    let public_input = "./sha3-chain/public_input.json".to_string();
    let private_input = "./sha3-chain/private_input.json".to_string();
    let trace = "./sha3-chain/trace.bin".to_string();
    let memory = "./sha3-chain/memory.bin".to_string();

    println!("Generating Prover Input Files...");
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

    let run_command = format!(
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        output_path, program_input, public_input, private_input, trace, memory,
    );
    println!("cairo-run: {:?}", run_command);
    let output = Command::new("sh")
        .arg("-c")
        .arg(run_command)
        .output();
    match output {
        Ok(output) if output.status.success() => {
            println!("cairo-run successful!");
            println!("stdout: {}", String::from_utf8_lossy(&output.stdout));
        }
        Ok(output) => {
            eprintln!(
                "cairo-run failed with exit code: {}",
                output.status.code().unwrap_or(-1)
            );
            eprintln!("stderr: {}", String::from_utf8_lossy(&output.stderr));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-run: {}", err);
        }
    }

    prove_and_verify(public_input, private_input)
}

fn bench_ec(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./ec/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "../stone/ec/programs/ec_add.cairo".to_string();
    let output_path = "./ec/ec.json".to_string();

    let public_input = "./ec/public_input.json".to_string();
    let private_input = "./ec/private_input.json".to_string();
    let trace = "./ec/trace.bin".to_string();
    let memory = "./ec/memory.bin".to_string();

    println!("Generating Prover Input Files...");
    let status = Command::new("cairo-compile")
        .arg(&program_path)
        .arg("--output")
        .arg(&output_path)
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

    let run_command = format!(
        "cairo-run --program={} --cairo_layout_params_file=../stone/configs/cairo_layout_params_file.json --layout=dynamic --program_input={} --air_public_input={} --air_private_input={} --trace_file={} --memory_file={} --proof_mode", 
        output_path, program_input, public_input, private_input, trace, memory,
    );
    println!("cairo-run: {:?}", run_command);
    let output = Command::new("sh")
        .arg("-c")
        .arg(run_command)
        .output();
    match output {
        Ok(output) if output.status.success() => {
            println!("cairo-run successful!");
            println!("stdout: {}", String::from_utf8_lossy(&output.stdout));
        }
        Ok(output) => {
            eprintln!(
                "cairo-run failed with exit code: {}",
                output.status.code().unwrap_or(-1)
            );
            eprintln!("stderr: {}", String::from_utf8_lossy(&output.stderr));
        }
        Err(err) => {
            eprintln!("Failed to run cairo-run: {}", err);
        }
    }

    prove_and_verify(public_input, private_input)
}

use util::gen_prover_input;

fn bench_blake(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./blake/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "./blake/blake_with_opcode.cairo".to_string();
    let output_path = "./blake/blake.json".to_string();

    let public_input = "./blake/public_input.json".to_string();
    let private_input = "./blake/private_input.json".to_string();

    let output_dir = "./blake".to_string();

    println!("Generating Prover Input Files...");
    let status = Command::new("cairo-compile")
        .arg(&program_path)
        .arg("--output")
        .arg(&output_path)
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

    gen_prover_input(&output_path, program_input, &output_dir);

    prove_and_verify(public_input, private_input)
}

fn bench_blake_chain(n: u32) -> (Duration, usize, Duration, usize) {

    let input = format!("{{\"iterations\": {}}}", n);
    let program_input = "./blake-chain/input.json";
    fs::write(program_input, input).expect("Failed to write input file");

    let program_path = "./blake-chain/blake_chain_with_opcode.cairo".to_string();
    let output_path = "./blake-chain/blake-chain.json".to_string();

    let public_input = "./blake-chain/public_input.json".to_string();
    let private_input = "./blake-chain/private_input.json".to_string();

    let output_dir = "./blake-chain".to_string();

    println!("Generating Prover Input Files...");
    let status = Command::new("cairo-compile")
        .arg(&program_path)
        .arg("--output")
        .arg(&output_path)
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

    gen_prover_input(&output_path, program_input, &output_dir);

    prove_and_verify(public_input, private_input)
}
