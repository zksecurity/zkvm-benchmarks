use core::felt252;

fn main(input: Array<felt252>) -> Array<felt252> {
    let mut input = input.span();
    let n: felt252 = Serde::deserialize(ref input).unwrap();

    let result = fib(1, 1, n);
    
    let mut output: Array<felt252> = ArrayTrait::new();
    result.serialize(ref output);
    output
}

fn fib(a: felt252, b: felt252, n: felt252) -> felt252 {
    match n {
        0 => a,
        _ => fib(b, a + b, n - 1),
    }
}