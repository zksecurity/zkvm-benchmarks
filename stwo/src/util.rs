use stwo_cairo_prover::stwo_prover::core::vcs::blake2_merkle::Blake2sMerkleChannel;
use stwo_cairo_adapter::vm_import::adapt_vm_output;
use stwo_cairo_adapter::ProverInput;
use stwo_cairo_prover::cairo_air::prover::{
    default_prod_prover_parameters, prove_cairo, ProverParameters, ProverConfig,
};
use stwo_cairo_prover::cairo_air::verifier::verify_cairo;

use std::path::Path;
use std::time::{Duration, Instant};
use utils::size;

pub fn prove_and_verify(stwo_public_input: String, stwo_private_input: String) -> (Duration, usize, Duration, usize) {
    println!("Running Stwo Prover...");
    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&stwo_public_input), Path::new(&stwo_private_input)).unwrap();
    let ProverParameters { pcs_config } = default_prod_prover_parameters();
    let config = ProverConfig {
        display_components: false,
    };
    let prover_start = Instant::now();
    let proof = prove_cairo::<Blake2sMerkleChannel>(vm_output, config, pcs_config).unwrap();
    let prover_end = Instant::now();
    println!("Proof Generated Successfully...");

    let proof_size = size(&proof);
    
    println!("Running Stwo Verifier...");
    let verifier_start = Instant::now();
    verify_cairo::<Blake2sMerkleChannel>(proof, pcs_config).unwrap();
    let verifier_end = Instant::now();
    println!("Proof Verified Successfully...");

    let vm_output: ProverInput =
        adapt_vm_output(Path::new(&stwo_public_input), Path::new(&stwo_private_input)).unwrap();
    let counts = &vm_output.state_transitions.casm_states_by_opcode.counts();
    let cycle_count = counts.iter().map(|(_, count)| count).sum::<usize>();

    (prover_end.duration_since(prover_start), proof_size, verifier_end.duration_since(verifier_start), cycle_count)
}