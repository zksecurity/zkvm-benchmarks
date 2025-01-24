#![no_main]
// If you want to try std support, also update the guest Cargo.toml file
#![no_std]  // std support is experimental

extern crate alloc;

use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);


pub fn main() {
    let n = env::read::<u32>();

    let res = match n {
        10 => matrix_mul_100(),
        20 => matrix_mul_500(),
        40 => matrix_mul_1000(),
        60 => matrix_mul_10000(),
        _ => panic!("Invalid input")
    };

    env::commit(&res);
}

fn matrix_mul_100() -> u32 {
    const SIZE: usize = 10;

    let a = [[2u32; SIZE]; SIZE];
    let b = [[3u32; SIZE]; SIZE];

    let mut result = [[0u32; SIZE]; SIZE];
    
    let mut total = 0;

    for i in 0..SIZE {
        // let mut new_row = [0u32; SIZE];
        for j in 0..SIZE {
            let mut sum = 0;
            for k in 0..SIZE {
                result[i][j] += a[i][k] * b[k][j];
                sum += a[i][k] * b[k][j];
            }
            total += sum;
        }
    }

    total
}

fn matrix_mul_500() -> u32 {
    const SIZE: usize = 20;

    let a = [[2u32; SIZE]; SIZE];
    let b = [[3u32; SIZE]; SIZE];
    // let mut result = [[0u32; SIZE]; SIZE];
    
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

fn matrix_mul_1000() -> u32 {
    const SIZE: usize = 40;

    let a = [[2u32; SIZE]; SIZE];
    let b = [[3u32; SIZE]; SIZE];
    // let mut result = [[0u32; SIZE]; SIZE];
    
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

fn matrix_mul_10000() -> u32 {
    const SIZE: usize = 60;

    let a = [[2u32; SIZE]; SIZE];
    let b = [[3u32; SIZE]; SIZE];
    // let mut result = [[0u32; SIZE]; SIZE];
    

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
