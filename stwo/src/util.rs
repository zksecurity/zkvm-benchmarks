use stwo_cairo_prover::stwo_prover::core::vcs::blake2_merkle::Blake2sMerkleChannel;
use stwo_cairo_adapter::vm_import::adapt_vm_output;
use stwo_cairo_adapter::ProverInput;
use stwo_cairo_prover::prover::prove_cairo;
use stwo_cairo_prover::stwo_prover::core::pcs::PcsConfig;
use stwo_cairo_prover::stwo_prover::core::fri::FriConfig;
use cairo_air::verifier::verify_cairo;
use cairo_air::PreProcessedTraceVariant;

use std::path::Path;
use std::time::{Duration, Instant};
use std::process::Command;
use utils::size;

use std::collections::HashMap;
use std::rc::Rc;
use cairo_vm::Felt252;
use cairo_vm::air_public_input::PublicInput;

use cairo_vm::cairo_run::{
    cairo_run_program, write_encoded_memory, write_encoded_trace, CairoRunConfig,
};
use cairo_vm::vm::runners::cairo_runner::CairoRunner;
use cairo_vm::hint_processor::builtin_hint_processor::builtin_hint_processor_definition::{
    BuiltinHintProcessor, HintFunc,
};
use cairo_vm::hint_processor::builtin_hint_processor::hint_utils::insert_value_from_var_name;
use cairo_vm::types::layout::CairoLayoutParams;
use cairo_vm::types::program::Program;
use std::io::{self, BufWriter, Write};
use cairo_vm::air_public_input::PublicInputError;
use bincode::enc::write::Writer;

pub fn prove_and_verify(
    program_input: String,
    program_path: String, 
    output_path: String, 
    public_input: String, 
    private_input: String, 
    _trace: String, 
    _memory: String,
    out_dir: String,
) -> (Duration, usize, Duration, usize) {
    
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

    gen_prover_input(&output_path, &program_input, &out_dir);

    println!("Running Stwo Prover...");
    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&public_input), Path::new(&private_input)).unwrap();
    let pcs_config = PcsConfig {
        pow_bits: 26,
        fri_config: FriConfig {
            log_last_layer_degree_bound: 0,
            log_blowup_factor: 1,
            n_queries: 70,
        },
    };
    let preprocessed_trace = PreProcessedTraceVariant::CanonicalWithoutPedersen;
    let prover_start = Instant::now();
    let proof = prove_cairo::<Blake2sMerkleChannel>(vm_output, pcs_config, preprocessed_trace).unwrap();
    let prover_end = Instant::now();
    println!("Proof Generated Successfully...");

    let proof_size = size(&proof);
    
    println!("Running Stwo Verifier...");
    let verifier_start = Instant::now();
    verify_cairo::<Blake2sMerkleChannel>(proof, pcs_config, preprocessed_trace).unwrap();
    let verifier_end = Instant::now();
    println!("Proof Verified Successfully...");

    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&public_input), Path::new(&private_input)).unwrap();
    let counts = &vm_output.state_transitions.casm_states_by_opcode.counts();
    let cycle_count = counts.iter().map(|(_, count)| count).sum::<usize>();

    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}

pub fn gen_prover_input(
    program_file: &str,
    program_input_file: &str,
    output_dir: &str,
) {
    let program = Program::from_file(Path::new(program_file), Some("main")).unwrap();
    let program_input = {
        let program_input_file_str = std::fs::read_to_string(program_input_file).unwrap();
        serde_json::from_str::<HashMap<String, serde_json::Value>>(&program_input_file_str).unwrap()
    };

    let mut hint_processor = BuiltinHintProcessor::new_empty();
    let program_input_clone = program_input.clone();
    hint_processor.add_hint(
        "ids.iterations = program_input['iterations']".to_string(),
        Rc::new(HintFunc(Box::new(
            move |vm, _exec_scopes, ids_data, ap_tracking, _constants| {
                let iterations = program_input_clone
                    .get("iterations")
                    .unwrap()
                    .as_u64()
                    .unwrap();
                insert_value_from_var_name(
                    "iterations",
                    Felt252::from(iterations),
                    vm,
                    ids_data,
                    ap_tracking,
                ).unwrap();
                Ok(())
            },
        ))),
    );

    let cairo_layout_params_file = Path::new("./cairo_layout_params_file.json");
    let cairo_run_config = CairoRunConfig {
        entrypoint: "main",
        trace_enabled: true,
        relocate_mem: true,
        layout: cairo_vm::types::layout_name::LayoutName::dynamic,
        proof_mode: true,
        secure_run: None,
        disable_trace_padding: false,
        allow_missing_builtins: None,
        dynamic_layout_params: Some(CairoLayoutParams::from_file(
            cairo_layout_params_file,
        ).unwrap()),
    };

    let runner = cairo_run_program(&program, &cairo_run_config, &mut hint_processor).unwrap();
    
    let output_dir = Path::new(output_dir);
    write_to_files(&runner, output_dir);
}

fn write_to_files(
    runner: &CairoRunner,
    output_dir: &Path,
) {
    std::fs::create_dir_all(output_dir).unwrap();

    let trace_path = output_dir.join("trace.json");
    let trace_file = std::fs::File::create(&trace_path).unwrap();
    let mut trace_writer =
        FileWriter::new(io::BufWriter::with_capacity(3 * 1024 * 1024, trace_file));
    write_encoded_trace(runner.relocated_trace.as_ref().unwrap(), &mut trace_writer).unwrap();
    trace_writer.flush().unwrap();

    let memory_path = output_dir.join("memory.json");
    let memory_file = std::fs::File::create(&memory_path).unwrap();
    let mut memory_writer =
        FileWriter::new(io::BufWriter::with_capacity(5 * 1024 * 1024, memory_file));
    write_encoded_memory(&runner.relocated_memory, &mut memory_writer).unwrap();
    memory_writer.flush().unwrap();
    
    let air_public_input_path = output_dir.join("public_input.json");
    let air_public_input_str = get_formatted_air_public_input(&runner.get_air_public_input().unwrap()).unwrap();
    std::fs::write(&air_public_input_path, air_public_input_str).unwrap();

    let air_private_input_path = output_dir.join("private_input.json");
    let trace_absolute_path = trace_path.canonicalize().unwrap_or(trace_path.clone()).to_str().unwrap().to_string();
    let memory_absolute_path = memory_path.canonicalize().unwrap_or(memory_path.clone()).to_str().unwrap().to_string();
    let air_private_input = runner
        .get_air_private_input()
        .to_serializable(trace_absolute_path, memory_absolute_path)
        .serialize_json()
        .map_err(PublicInputError::Serde).unwrap();
    std::fs::write(&air_private_input_path, air_private_input).unwrap();

}


pub struct FileWriter {
    buf_writer: BufWriter<std::fs::File>,
    bytes_written: usize,
}

impl Writer for FileWriter {
    fn write(&mut self, bytes: &[u8]) -> Result<(), bincode::error::EncodeError> {
        self.buf_writer
            .write_all(bytes)
            .map_err(|e| bincode::error::EncodeError::Io {
                inner: e,
                index: self.bytes_written,
            })?;

        self.bytes_written += bytes.len();

        Ok(())
    }
}

impl FileWriter {
    pub fn new(buf_writer: BufWriter<std::fs::File>) -> Self {
        Self {
            buf_writer,
            bytes_written: 0,
        }
    }

    pub fn flush(&mut self) -> io::Result<()> {
        self.buf_writer.flush()
    }
}

pub fn get_formatted_air_public_input(
    air_public_input: &PublicInput,
) -> Result<String, PublicInputError> {
    let mut air_public_input: serde_json::Value =
        serde_json::from_str(&air_public_input.serialize_json()?)?;

    // Check if "public_memory" exists and is an array
    if let Some(public_memory) = air_public_input
        .get_mut("public_memory")
        .and_then(|v| v.as_array_mut())
    {
        // Iterate through each item in the "public_memory" array
        for item in public_memory {
            // Check if the item has a "value" field
            if let Some(value) = item.get_mut("value").and_then(|v| v.as_str()) {
                // Prepend "0x" to the value if it doesn't already start with "0x"
                if !value.starts_with("0x") {
                    let new_value = format!("0x{}", value);
                    item["value"] = serde_json::Value::String(new_value);
                }
            }
        }
    }
    // Convert the modified JSON back to a string
    let air_public_input_str = serde_json::to_string(&air_public_input)?;

    Ok(air_public_input_str)
}