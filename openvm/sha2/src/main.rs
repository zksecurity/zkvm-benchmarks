#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use sha2::{Sha256, Digest};

extern crate alloc;

use alloc::vec::Vec;
use openvm::io::{read, reveal_bytes32};
use core::hint::black_box;

openvm::entry!(main);

pub fn main() {
    let input: Vec<u8> = read();

    let mut hasher = Sha256::new();
    hasher.update(&black_box(input));
    let result = hasher.finalize();
    reveal_bytes32(&Into::<[u8; 32]>::into(result));
}
