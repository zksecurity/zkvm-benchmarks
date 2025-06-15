#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use core::hint::black_box;

use openvm_sha2::sha256;

use openvm::io::{read, reveal_bytes32};

extern crate alloc;

use alloc::vec::Vec;

openvm::entry!(main);

pub fn main() {
    let num_iters: u32 = read();
    let mut input: Vec<u8> = read();

    for _ in 0..num_iters {
        let output = sha256(&black_box(input));
        input = output.to_vec();
    }
    let arr: [u8; 32] = input.try_into().expect("input must be 32 bytes");
    reveal_bytes32(arr);
}
