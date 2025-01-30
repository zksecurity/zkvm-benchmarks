#![no_main]

sp1_zkvm::entrypoint!(main);

use secp256k1::{Secp256k1, SecretKey, PublicKey};

pub fn main() {
    let mut n = sp1_zkvm::io::read::<u32>();

    let one = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
    let secp = Secp256k1::new();
    let secret_key = SecretKey::from_slice(&one).unwrap();
    let g = PublicKey::from_secret_key(&secp, &secret_key);

    while n != 0 {
        let _ = PublicKey::combine(&g, &g);
        n -= 1;
    }

    sp1_zkvm::io::commit(&n);
}
