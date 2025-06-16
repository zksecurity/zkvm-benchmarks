use risc0_zkvm::guest::env;

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
