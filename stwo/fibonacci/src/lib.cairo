use core::felt252;

#[executable]
fn main(input: felt252) -> felt252 {
    let result = fib(0, 1, input);
    
    result
}

fn fib(a: felt252, b: felt252, n: felt252) -> felt252 {
    match n {
        0 => a,
        _ => fib(b, a + b, n - 1),
    }
}