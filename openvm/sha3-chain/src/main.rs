#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use sha3::{Keccak256, Digest};

use openvm::io::read;

openvm::entry!(main);

pub fn main() {
    let num_iters: u32 = read();
    let input = [5u8; 32];

    for _ in 0..num_iters {
        let mut hasher = Keccak256::new();
        hasher.update(input);
        let _res = &hasher.finalize();
    }
}
