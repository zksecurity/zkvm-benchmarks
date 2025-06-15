#![no_main]
sp1_zkvm::entrypoint!(main);

pub fn main() {
    let n = sp1_zkvm::io::read::<u32>();

    let mut a: u32 = 0;
    let mut b: u32 = 1;
    let mut sum: u32;
    for _ in 1..n {
        sum = a.wrapping_add(b);
        a = b;
        b = sum;
    }

    sp1_zkvm::io::commit(&b);
}