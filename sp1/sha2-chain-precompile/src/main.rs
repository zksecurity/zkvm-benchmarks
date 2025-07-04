#![no_main]

use sha2::{Digest, Sha256};

sp1_zkvm::entrypoint!(main);
use core::hint::black_box;

pub fn main() {
    let input: [u8; 32] = sp1_zkvm::io::read();
    let num_iters: u32 = sp1_zkvm::io::read();
    let mut hash = input;
    for _ in 0..num_iters {
        let mut hasher = Sha256::new();
        hasher.update(&black_box(hash));
        let res = &hasher.finalize();
        hash = Into::<[u8; 32]>::into (*res);
    }

    sp1_zkvm::io::commit::<[u8; 32]>(&hash.into());
}
