#![no_main]
#![no_std]

use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);
use tiny_keccak::{Hasher, Keccak};
use core::hint::black_box;

fn main() {
    let mut input: [u8; 32] = env::read();
    let num_iters: u32 = env::read();
    let mut output = [0u8; 32];
    for _ in 0..num_iters {
        let mut hasher = Keccak::v256();
        hasher.update(&black_box(input));
        hasher.finalize(&mut output);
        input = output.into();
    }

    env::commit::<[u8; 32]>(&output.into());
}
