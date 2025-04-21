use risc0_zkvm::guest::env;

use k256::ProjectivePoint;
use std::ops::Add;


fn main() {
    let mut n = env::read::<u32>();
    let mut g = ProjectivePoint::GENERATOR;

    while n != 0 {
        g = ProjectivePoint::add(g, &g);
        n -= 1;
    }

    env::commit(&n);
}
