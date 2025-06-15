#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm_keccak256::keccak256;
use core::hint::black_box;

use openvm::io::{read, reveal_bytes32};

extern crate alloc;

use alloc::vec::Vec;

openvm::entry!(main);

pub fn main() {
    let num_iters: u32 = read();
    let mut input: Vec<u8> = read();

    for _ in 0..num_iters {
        let output = keccak256(&black_box(input));
        input = output.to_vec();
    }
    reveal_bytes32(&Into::<[u8; 32]>::into(input));
}
