%builtins range_check bitwise keccak

from starkware.cairo.common.builtin_keccak.keccak import keccak
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, KeccakBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.alloc import alloc

// For usage refer the following link:
// https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/builtin_keccak/keccak.cairo#L1-L11

// The main function now accepts a parameter `n` that indicates how many times to hash.
func main{range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*, keccak_ptr: KeccakBuiltin*}() {
    alloc_locals;

    local iterations;
    %{ ids.iterations = program_input['iterations'] %}

    let (inputs: felt*) = alloc();
    let n_bytes = 32;
    fill_input(input=inputs, length=n_bytes / 8, iterator=0);

    let final_state = repeat_hash(inputs, iterations-1);

    return ();
}

func fill_input(input: felt*, length: felt, iterator: felt) {
    if (iterator == length) {
        return ();
    }
    assert input[iterator] = 1;
    return fill_input(input, length, iterator + 1);
}

// A helper function that hashes the given state `n` times.
func repeat_hash{range_check_ptr, bitwise_ptr: BitwiseBuiltin*, keccak_ptr: KeccakBuiltin*}(inputs: felt*, iterations: felt) -> Uint256 {
    alloc_locals;

    if (iterations == 0) {
        let (res: Uint256) = keccak(inputs=inputs, n_bytes=32);
        return res;
    }

    let (res: Uint256) = keccak(inputs=inputs, n_bytes=32);
    return repeat_hash(inputs, iterations - 1);
}
