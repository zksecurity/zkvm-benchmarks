#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use sha2::{Sha256, Digest};

extern crate alloc;

use alloc::vec::Vec;

use openvm::io::{read, reveal_bytes32};

openvm::entry!(main);

use core::hint::black_box;

pub fn main() {
    let num_iters: u32 = read();
    let mut input: Vec<u8> = read();

    for _ in 0..num_iters {
        let mut hasher = Sha256::new();
        hasher.update(&black_box(input));
        let res = &hasher.finalize();
        input = res.to_vec();
    }
    let arr: [u8; 32] = input.try_into().expect("input must be 32 bytes");
    reveal_bytes32(arr);
}
