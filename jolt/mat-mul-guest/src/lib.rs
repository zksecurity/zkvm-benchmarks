#![cfg_attr(feature = "guest", no_std)]
#![no_main]

#[jolt::provable]
fn matrix_mul_100() -> u32 {
    // let size = size as usize;
    const size: usize = 100;

    let a = [[2u32; size]; size];
    let b = [[3u32; size]; size];
    
    // using mutable array throws error from the vm
    // let mut result = [[0u32; size]; size];
    // src/emulator/mmu.rs:248:13:
    // Unknown memory mapping: 0x68288F1C

    let mut sum = 0;
    for i in 0..size {
        for j in 0..size {
            for k in 0..size {
                // result[i][j] += a[i][k] * b[k][j];
                sum += a[i][k] * b[k][j];
            }
        }
    }

    sum
}

#[jolt::provable]
fn matrix_mul_500() -> u32 {
    // let size = size as usize;
    const size: usize = 500;

    let a = [[2u32; size]; size];
    let b = [[3u32; size]; size];
    
    let mut sum = 0;
    for i in 0..size {
        for j in 0..size {
            for k in 0..size {
                sum += a[i][k] * b[k][j];
            }
        }
    }

    sum
}

#[jolt::provable]
fn matrix_mul_1000() -> u32 {
    // let size = size as usize;
    const size: usize = 1000;

    let a = [[2u32; size]; size];
    let b = [[3u32; size]; size];
    
    let mut sum = 0;
    for i in 0..size {
        for j in 0..size {
            for k in 0..size {
                sum += a[i][k] * b[k][j];
            }
        }
    }

    sum
}

#[jolt::provable]
fn matrix_mul_10000() -> u32 {
    // let size = size as usize;
    const size: usize = 10000;

    let a = [[2u32; size]; size];
    let b = [[3u32; size]; size];
    

    let mut sum = 0;
    for i in 0..size {
        for j in 0..size {
            for k in 0..size {
                sum += a[i][k] * b[k][j];
            }
        }
    }

    sum
}
