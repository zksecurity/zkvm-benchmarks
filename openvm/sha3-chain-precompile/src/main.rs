#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm_keccak256_guest::keccak256;
use core::hint::black_box;

use openvm::io::read;

openvm::entry!(main);

pub fn main() {
    let num_iters: u32 = read();
    let input = [5u8; 32];

    for _ in 0..num_iters {
        let _output = keccak256(&black_box(input));
    }
}
