
use core::felt252;
use core::array::ArrayTrait;
use core::option::OptionTrait;

#[executable]
fn main(input: u32) -> Array<felt252> {
    let size: u32 = input;
    let mut a: Array<Array<felt252>> = ArrayTrait::new();
    let mut i = 0;
    loop {
        if i >= size {
            break;
        }
        let mut a_row: Array<felt252> = ArrayTrait::new();
        let mut j = 0;
        loop {
            if j >= size {
                break;
            }
            a_row.append(1); // initialize each element with 1
            j += 1;
        };
        a.append(a_row);
        i += 1;
    };

    let mut b: Array<Array<felt252>> = ArrayTrait::new();
    let mut x = 0;
    loop {
        if x >= size {
            break;
        }
        let mut b_row: Array<felt252> = ArrayTrait::new();
        let mut y = 0;
        loop {
            if y >= size {
                break;
            }
            b_row.append(2); // initialize each element with 2
            y += 1;
        };
        b.append(b_row);
        x += 1;
    };

    let result = matrix_mul_array(@a, @b);
    // result
    let mut output: Array<felt252> = ArrayTrait::new();

    result.at(0).serialize(ref output);
    output
}


fn matrix_mul_array(a: @Array<Array<felt252>>, b: @Array<Array<felt252>>) -> Array<Array<felt252>> {
    let a_row = a.len();
    let a_col = a.at(0).len();
    let b_row = b.len();
    let b_col = b.at(0).len();

    // Ensure dimensions are compatible: (a_row x a_col) * (b_row x b_col)
    // where a_col == b_row
    assert(a_col == b_row, 'Dimension mismatch');

    let mut result: Array<Array<felt252>> = ArrayTrait::new();

    let mut i = 0;
    loop {
        if i >= a_row {
            break;
        }
        let mut new_row: Array<felt252> = ArrayTrait::new();
        let mut j = 0;
        loop {
            if j >= b_col {
                break;
            }
            let mut sum = 0;
            let mut k = 0;
            loop {
                if k >= a_col {
                    break;
                }
                let a_val = a.at(i).at(k);
                let b_val = b.at(k).at(j);
                sum += *a_val * *b_val;
                k += 1;
            };
            new_row.append(sum);
            j += 1;
        };
        result.append(new_row);
        i += 1;
    };

    result
}
