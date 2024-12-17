#![cfg_attr(feature = "guest", no_std)]
#![no_main]

#[jolt::provable]
fn matrix_mul_100() -> u32 {
    const SIZE: usize = 100;

    let a = [[2u32; SIZE]; SIZE];
    let b = [[3u32; SIZE]; SIZE];
    
    // using mutable array throws error from the vm
    // let mut result = [[0u32; SIZE]; SIZE];
    // src/emulator/mmu.rs:248:13:
    // Unknown memory mapping: 0x68288F1C

    let mut sum = 0;
    for i in 0..SIZE {
        for j in 0..SIZE {
            for k in 0..SIZE {
                // result[i][j] += a[i][k] * b[k][j];
                sum += a[i][k] * b[k][j];
            }
        }
    }

    sum
}

#[jolt::provable]
fn matrix_mul_500() -> u32 {
    const SIZE: usize = 500;

    let a = [[2u32; SIZE]; SIZE];
    let b = [[3u32; SIZE]; SIZE];
    
    let mut sum = 0;
    for i in 0..SIZE {
        for j in 0..SIZE {
            for k in 0..SIZE {
                sum += a[i][k] * b[k][j];
            }
        }
    }

    sum
}

#[jolt::provable]
fn matrix_mul_1000() -> u32 {
    const SIZE: usize = 1000;

    let a = [[2u32; SIZE]; SIZE];
    let b = [[3u32; SIZE]; SIZE];
    
    let mut sum = 0;
    for i in 0..SIZE {
        for j in 0..SIZE {
            for k in 0..SIZE {
                sum += a[i][k] * b[k][j];
            }
        }
    }

    sum
}

#[jolt::provable]
fn matrix_mul_10000() -> u32 {
    const SIZE: usize = 10000;

    let a = [[2u32; SIZE]; SIZE];
    let b = [[3u32; SIZE]; SIZE];
    

    let mut sum = 0;
    for i in 0..SIZE {
        for j in 0..SIZE {
            for k in 0..SIZE {
                sum += a[i][k] * b[k][j];
            }
        }
    }

    sum
}
