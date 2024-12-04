#![cfg_attr(feature = "guest", no_std)]
#![no_main]

use sha2::{Sha256, Digest};


#[jolt::provable]
fn sha2(input: &[u8]) -> [u8; 32] {
    let mut hasher = Sha256::new();
    hasher.update(input);
    let result = hasher.finalize();
    Into::<[u8; 32]>::into(result)
}

