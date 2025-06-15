#![no_main]

use sha2::{Digest, Sha256};
extern crate alloc;
use core::hint::black_box;

sp1_zkvm::entrypoint!(main);

pub fn main() {
    let input: Vec<u8> = sp1_zkvm::io::read();

    let mut hasher = Sha256::new();
    hasher.update(&black_box(input));
    let result = hasher.finalize();

    sp1_zkvm::io::commit::<[u8; 32]>(&result.into());
}
