#![no_main]

use blake2::{Blake2s256, Digest};
extern crate alloc;
use core::hint::black_box;

sp1_zkvm::entrypoint!(main);

pub fn main() {
    let input: [u8; 32] = sp1_zkvm::io::read();
    let num_iters: u32 = sp1_zkvm::io::read();
    let mut hash = input;
    for _ in 0..num_iters {
        let mut hasher = Blake2s256::new();
        hasher.update(&black_box(hash));
        let res = &hasher.finalize();
        hash = Into::<[u8; 32]>::into (*res);
    }

    sp1_zkvm::io::commit::<[u8; 32]>(&hash.into());
}
