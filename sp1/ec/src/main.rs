#![no_main]

sp1_zkvm::entrypoint!(main);

use ark_secp256k1::{G_GENERATOR_X, G_GENERATOR_Y};
use ark_secp256k1::Affine;
use std::ops::Add;

pub fn main() {
    let n = sp1_zkvm::io::read::<u32>();
    let g = Affine::new_unchecked(
        G_GENERATOR_X,
        G_GENERATOR_Y
    );

    for _i in 0..n {
      let _ = Affine::add(g, g);  
    }

    sp1_zkvm::io::commit(&n);
}
