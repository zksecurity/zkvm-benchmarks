#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm::io::{read, reveal_bytes32};

use k256::{AffinePoint, ProjectivePoint};
use k256::elliptic_curve::point::AffineCoordinates;

openvm::entry!(main);

fn main() {
    let n: u32 = read();
    let g = AffinePoint::GENERATOR;
    let mut res = ProjectivePoint::from(g);

    for _ in 0..n {
        res += g;
    }

    let affine = AffinePoint::from(res);
    let x_bytes: [u8; 32] = affine.x().into();
    reveal_bytes32(x_bytes);
}