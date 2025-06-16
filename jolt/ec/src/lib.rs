#![cfg_attr(feature = "guest", no_std)]
#![no_main]

use k256::{AffinePoint, ProjectivePoint};
use k256::elliptic_curve::point::AffineCoordinates;


#[jolt::provable]
fn ecadd(n: u32) -> [u8; 32] {
    let g = AffinePoint::GENERATOR;
    let mut res = ProjectivePoint::from(g);

    for _ in 0..n {
        res += g;
    }

    let affine = AffinePoint::from(res);
    let x_bytes: [u8; 32] = affine.x().into();
    x_bytes
}

