#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm_keccak256_guest::keccak256;
use core::hint::black_box;

extern crate alloc;

use alloc::vec::Vec;
use openvm::io::read;

openvm::entry!(main);

pub fn main() {
    let input: Vec<u8> = read();

    let _output = keccak256(&black_box(input));
}
