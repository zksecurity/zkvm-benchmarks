#![no_main]
#![no_std]

use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);
use tiny_keccak::{Hasher, Keccak};

fn main() {
    let input: [u8; 32] = env::read();
    let num_iters: u32 = env::read();
    let mut output = [0u8; 32];
    for _ in 0..num_iters {
        let mut hasher = Keccak::v256();
        hasher.update(&input);
        hasher.finalize(&mut output);
    }

    env::commit::<[u8; 32]>(&output.into());
}
