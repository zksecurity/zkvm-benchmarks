#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm::io::{read, reveal_u32};

use ark_secp256k1::{G_GENERATOR_X, G_GENERATOR_Y};
use ark_secp256k1::Affine;
use core::ops::Add;

openvm::entry!(main);

fn main() {
    let n: u32 = read();
    let mut g = Affine::new_unchecked(
        G_GENERATOR_X,
        G_GENERATOR_Y
    );

    for _i in 0..n {
      g = Affine::add(g, g).into();
    }
    reveal_u32(n as u32, 0);
}