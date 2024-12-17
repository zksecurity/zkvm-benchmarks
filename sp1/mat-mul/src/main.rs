#![no_main]

extern crate alloc;
use alloc::vec;

sp1_zkvm::entrypoint!(main);

pub fn main() {
    let input: u32 = sp1_zkvm::io::read();

    let res = matrix_mul(input as usize);

    sp1_zkvm::io::commit::<u32>(&res.into());
}

fn matrix_mul(size: usize) -> u32 {
    let a = vec![vec![2u32; size]; size];
    let b = vec![vec![3u32; size]; size];
    
    let result = vec![vec![0u32; size]; size];
    let mut sum = 0;
    for i in 0..size {
        for j in 0..size {
            for k in 0..size {
                result[i][j] += a[i][k] * b[k][j];
                sum += a[i][k] * b[k][j];
            }
        }
    }

    sum
}