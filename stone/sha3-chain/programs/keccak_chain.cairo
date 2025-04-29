%builtins range_check bitwise

from starkware.cairo.common.cairo_keccak.keccak import cairo_keccak, finalize_keccak
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc

func main{range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}() {
    alloc_locals;

    local iterations;
    %{ ids.iterations = program_input['iterations'] %}

    let (inputs: felt*) = alloc();

    let n_bytes = 32;

    // each felt field has 251 bits, so it can hold 31 bytes
    // less input fields take much more memory (and crash on my machine)
    // so here we assume filling the input with 8 bytes

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
func repeat_hash{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(inputs: felt*, iterations: felt) -> Uint256 {
    alloc_locals;

    if (iterations == 0) {
        let (keccak_ptr: felt*) = alloc();
        let keccak_ptr_start = keccak_ptr;
        let (res: Uint256) = cairo_keccak{keccak_ptr=keccak_ptr}(inputs=inputs, n_bytes=32);
        finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);
        return res;
    }

    let (keccak_ptr: felt*) = alloc();
    let keccak_ptr_start = keccak_ptr;
    let (res: Uint256) = cairo_keccak{keccak_ptr=keccak_ptr}(inputs=inputs, n_bytes=32);
    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);

    return repeat_hash(inputs, iterations - 1);
}
