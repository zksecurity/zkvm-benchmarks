#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use core::hint::black_box;

use openvm_sha256_guest::sha256;

use openvm::io::read;

openvm::entry!(main);

pub fn main() {
    let num_iters: u32 = read();
    let mut input: Vec<u8> = read();

    for _ in 0..num_iters {
        let output = sha256(&black_box(input));
        input = Into::<[u8; 32]>::into(*output);
    }
}
