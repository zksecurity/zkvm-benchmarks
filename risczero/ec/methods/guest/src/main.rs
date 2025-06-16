#![no_main]
// If you want to try std support, also update the guest Cargo.toml file
#![no_std]  // std support is experimental


use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);

use k256::{AffinePoint, ProjectivePoint};
use k256::elliptic_curve::point::AffineCoordinates;


fn main() {
    let n = env::read::<u32>();
    let g = AffinePoint::GENERATOR;
    let mut res = ProjectivePoint::from(g);

    for _ in 0..n {
        res += g;
    }

    let affine = AffinePoint::from(res);
    let x_bytes: [u8; 32] = affine.x().into();

    env::commit::<[u8; 32]>(&x_bytes);
}
