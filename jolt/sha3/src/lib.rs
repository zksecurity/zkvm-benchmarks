#![cfg_attr(feature = "guest", no_std)]
#![no_main]

use sha3::{Keccak256, Digest};
use core::hint::black_box;


#[jolt::provable]
fn sha3(input: &[u8]) -> [u8; 32] {
    let mut hasher = Keccak256::new();
    hasher.update(&black_box(input));
    let result = hasher.finalize();
    Into::<[u8; 32]>::into(result)
}

