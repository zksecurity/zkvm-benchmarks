#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm::io::{read, reveal_u32};

use openvm_ecc_guest::{
    k256::Secp256k1Point,
};

use openvm_ecc_guest::CyclicGroup;

openvm_ecc_sw_macros::sw_init! {
    Secp256k1Point,
};

openvm::entry!(main);

fn main() {
    let n: u32 = read();
    let g = Secp256k1Point::GENERATOR;
    let mut res = Secp256k1Point::GENERATOR;

    for _i in 0..n {
      res = res + &g;
    }
    reveal_u32(n as u32, 0);
}