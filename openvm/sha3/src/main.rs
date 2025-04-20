#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use sha3::{Keccak256, Digest};

extern crate alloc;

use alloc::vec::Vec;
use openvm::io::read;

openvm::entry!(main);

pub fn main() {
    let input: Vec<u8> = read();

    let mut hasher = Keccak256::new();
    hasher.update(input);
    let _result = hasher.finalize();
}
