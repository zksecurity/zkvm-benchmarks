#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

extern crate alloc;

use alloc::vec::Vec;
use core::hint::black_box;

use openvm_sha2::sha256;

use openvm::io::{read, reveal_bytes32};

openvm::entry!(main);

pub fn main() {
    let input: Vec<u8> = read();
    let output = sha256(&black_box(input));
    reveal_bytes32(&Into::<[u8; 32]>::into(output));
}
