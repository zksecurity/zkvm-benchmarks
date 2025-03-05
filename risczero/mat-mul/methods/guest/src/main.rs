#![no_main]
// If you want to try std support, also update the guest Cargo.toml file
#![no_std]  // std support is experimental

extern crate alloc;
use alloc::vec;

use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);


pub fn main() {
    let n = env::read::<u32>();

    let res = matrix_mul(n as usize);

    env::commit(&res);
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