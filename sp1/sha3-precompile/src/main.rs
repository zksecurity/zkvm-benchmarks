#![no_main]

use sha3::{Digest, Keccak256};
extern crate alloc;
use core::hint::black_box;


sp1_zkvm::entrypoint!(main);

pub fn main() {
    let input: Vec<u8> = sp1_zkvm::io::read();

    let mut hasher = Keccak256::new();
    hasher.update(&black_box(input));
    let result = hasher.finalize();

    sp1_zkvm::io::commit::<[u8; 32]>(&result.into());
}
