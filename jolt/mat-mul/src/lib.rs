#![cfg_attr(feature = "guest", no_std)]
#![no_main]

#[jolt::provable]
fn matrix_mul_10() -> u32 {
    const SIZE: usize = 10;

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
fn matrix_mul_20() -> u32 {
    const SIZE: usize = 20;

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
fn matrix_mul_40() -> u32 {
    const SIZE: usize = 40;

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
fn matrix_mul_60() -> u32 {
    const SIZE: usize = 60;

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
