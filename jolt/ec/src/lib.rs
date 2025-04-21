#![cfg_attr(feature = "guest", no_std)]
#![no_main]

use ark_secp256k1::{G_GENERATOR_X, G_GENERATOR_Y};
use ark_secp256k1::Affine;
use core::ops::Add;


#[jolt::provable]
fn ecadd(n: u32) {
    let mut g = Affine::new_unchecked(
        G_GENERATOR_X,
        G_GENERATOR_Y
    );

    for _i in 0..n {
      g = Affine::add(g, g).into();
    }

}

