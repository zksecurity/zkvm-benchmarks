#![no_main]
// If you want to try std support, also update the guest Cargo.toml file
#![no_std]  // std support is experimental


use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);


fn main() {
    let n = env::read::<u32>();
    let mut a: u32 = 0;
    let mut b: u32 = 1;
    let mut sum: u32;
    for _ in 1..n {
        sum = a.wrapping_add(b);
        a = b;
        b = sum;
    }

    env::commit(&b);
}
