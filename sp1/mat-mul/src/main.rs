#![no_main]

extern crate alloc;
use alloc::vec;
use core::hint::black_box;

sp1_zkvm::entrypoint!(main);

pub fn main() {
    let input: u32 = sp1_zkvm::io::read();

    let res = matrix_mul(input as usize);

    sp1_zkvm::io::commit::<u32>(&res.into());
}

fn matrix_mul(size: usize) -> u32 {
    let mut a = vec![vec![2u32; size]; size];
    let mut b = vec![vec![3u32; size]; size];

    black_box(&mut a);
    black_box(&mut b);

    let mut result = vec![vec![0u32; size]; size];
    let mut sum = 0u32;
    for i in 0..size {
        for j in 0..size {
            for k in 0..size {
                let prod = a[i][k].wrapping_mul(b[k][j]);
                result[i][j] = result[i][j].wrapping_add(prod);
                sum = sum.wrapping_add(prod);
            }
        }
    }

    sum
}