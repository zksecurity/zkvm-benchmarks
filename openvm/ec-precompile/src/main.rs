#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm::io::{read, reveal_bytes32};

use openvm_k256::Secp256k1Point;
use openvm_ecc_guest::CyclicGroup;

openvm_algebra_guest::moduli_macros::moduli_init! {
    "0xFFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE FFFFFC2F",
    "0xFFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141"
}

openvm_ecc_guest::sw_macros::sw_init! {
    Secp256k1Point,
}

openvm::entry!(main);

fn main() {
    let n: u32 = read();
    let g = Secp256k1Point::GENERATOR;
    let mut res = g;

    for _i in 0..n {
      res = res + &g;
    }
    let x_bytes: [u8; 32] = res.x().into();
    reveal_bytes32(x_bytes);
}