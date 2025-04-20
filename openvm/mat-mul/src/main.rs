#![cfg_attr(not(feature = "std"), no_main)]
#![cfg_attr(not(feature = "std"), no_std)]

use openvm::io::{read, reveal_u32};
extern crate alloc;
use alloc::vec;

openvm::entry!(main);

pub fn main() {
    let input: u32 = read();

    let res = matrix_mul(input as usize);
    
    reveal_u32(res as u32, 0);
}

fn matrix_mul(size: usize) -> u32 {
    let a = vec![vec![2u32; size]; size];
    let b = vec![vec![3u32; size]; size];
    
    let mut result = vec![vec![0u32; size]; size];
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