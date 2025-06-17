#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm::io::{read, reveal_u32};

openvm::entry!(main);

fn main() {
    let n: u32 = read();
    let mut a: u32 = 0;
    let mut b: u32 = 1;
    for _ in 1..n {
        let c: u32 = a.wrapping_add(b);
        a = b;
        b = c;
    }
    reveal_u32(b as u32, 0);
}