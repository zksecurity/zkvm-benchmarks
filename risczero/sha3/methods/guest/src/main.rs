#![no_main]
#![no_std]

extern crate alloc;
use risc0_zkvm::guest::env;
use alloc::vec::Vec;

risc0_zkvm::guest::entry!(main);

use tiny_keccak::{Hasher, Keccak};

fn main() {
    let input: Vec<u8> = env::read();
    let mut output = [0u8; 32];

    let mut hasher = Keccak::v256();
    hasher.update(&input);
    hasher.finalize(&mut output);

    env::commit::<[u8; 32]>(&output.into());
}
