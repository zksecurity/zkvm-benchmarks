#![cfg_attr(feature = "guest", no_std)]
#![no_main]

use blake2::{Blake2s256, Digest};
use core::hint::black_box;


#[jolt::provable]
fn blake(input: &[u8]) -> [u8; 32] {
    let mut hasher = Blake2s256::new();
    hasher.update(&black_box(input));
    let result = hasher.finalize();
    Into::<[u8; 32]>::into(result)
}
