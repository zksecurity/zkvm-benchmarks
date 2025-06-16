#![no_main]

sp1_zkvm::entrypoint!(main);

use k256::{AffinePoint, ProjectivePoint};
use k256::elliptic_curve::point::AffineCoordinates;

pub fn main() {
    let n = sp1_zkvm::io::read::<u32>();
    let g = AffinePoint::generator();
    let mut res = ProjectivePoint::from(g);

    for _ in 0..n {
        res += g;
    }

    let affine = AffinePoint::from(res);
    let x_bytes: [u8; 32] = affine.x().into();

    sp1_zkvm::io::commit::<[u8; 32]>(&x_bytes);
}
