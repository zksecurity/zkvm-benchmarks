#![no_main]
#![no_std]

extern crate alloc;
use risc0_zkvm::guest::env;
use alloc::vec::Vec;
use core::hint::black_box;

risc0_zkvm::guest::entry!(main);

use blake2::{Blake2s256, Digest};

fn main() {
    let input: Vec<u8> = env::read();

    let mut hasher = Blake2s256::new();
    hasher.update(&black_box(input));
    let result = hasher.finalize();

    env::commit::<[u8; 32]>(&result.into());
}
