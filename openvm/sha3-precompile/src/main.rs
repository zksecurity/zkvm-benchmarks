#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm_keccak256::keccak256;
use core::hint::black_box;

extern crate alloc;

use alloc::vec::Vec;
use openvm::io::{read, reveal_bytes32};

openvm::entry!(main);

pub fn main() {
    let input: Vec<u8> = read();

    let output = keccak256(&black_box(input));
    reveal_bytes32(&Into::<[u8; 32]>::into(output));
}
