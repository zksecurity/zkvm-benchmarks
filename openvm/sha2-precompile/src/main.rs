#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

extern crate alloc;

use alloc::vec::Vec;
use core::hint::black_box;

use openvm_sha256_guest::sha256;

use openvm::io::read;

openvm::entry!(main);

pub fn main() {
    let input: Vec<u8> = read();
    let _output = sha256(&black_box(input));
}
