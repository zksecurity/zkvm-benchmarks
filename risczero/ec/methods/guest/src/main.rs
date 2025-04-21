#![no_main]
// If you want to try std support, also update the guest Cargo.toml file
#![no_std]  // std support is experimental


use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);

use ark_secp256k1::{G_GENERATOR_X, G_GENERATOR_Y};
use ark_secp256k1::Affine;
use core::ops::Add;


fn main() {
    let n = env::read::<u32>();
    let mut g = Affine::new_unchecked(
        G_GENERATOR_X,
        G_GENERATOR_Y
    );

    for _i in 0..n {
      g = Affine::add(g, g).into();
    }

    env::commit(&n);
}
