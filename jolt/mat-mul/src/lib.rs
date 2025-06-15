#![cfg_attr(feature = "guest", no_std)]
#![no_main]

extern crate alloc;
use alloc::vec;
use core::hint::black_box;

#[jolt::provable]
fn matrix_mul(size: usize) -> u32 {

    let a = vec![vec![2u32; size]; size];
    let b = vec![vec![3u32; size]; size];

    black_box(&a);
    black_box(&b);
    
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
