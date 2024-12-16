#![cfg_attr(feature = "guest", no_std)]
#![no_main]

#[jolt::provable]
fn matrix_mul() -> [[u32; 10]; 10] {
    // let size = size as usize;
    const size: usize = 10;

    let a = [[2u32; size]; size];
    let b = [[3u32; size]; size];
    
    let mut result = [[0u32; size]; size];

    for i in 0..size {
        for j in 0..size {
            for k in 0..size {
                result[i][j] += a[i][k] * b[k][j];
            }
        }
    }

    result

}
