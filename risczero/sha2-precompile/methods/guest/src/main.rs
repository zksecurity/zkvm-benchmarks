#![no_main]
#![no_std]

extern crate alloc;
use risc0_zkvm::guest::env;
use alloc::vec::Vec;

risc0_zkvm::guest::entry!(main);

use sha2::{Digest, Sha256};
use core::hint::black_box;

fn main() {
    let input: Vec<u8> = env::read();

    let mut hasher = Sha256::new();
    hasher.update(&black_box(input));
    let result = hasher.finalize();

    env::commit::<[u8; 32]>(&result.into());
}
