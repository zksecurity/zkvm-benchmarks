%builtins range_check bitwise

from starkware.cairo.common.cairo_keccak.keccak import cairo_keccak, finalize_keccak
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc

func main{range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}() {
    alloc_locals;

    // because the stone-cli only expose the input keyed by 'iterations'
    // here variable is called iterations to represent n_bytes
    local iterations;
    %{ ids.iterations = program_input['iterations'] %}

    let (keccak_ptr: felt*) = alloc();
    let keccak_ptr_start = keccak_ptr;

    let (inputs: felt*) = alloc();

    // each felt field has 251 bits, so it can hold 31 bytes
    // less input fields take much more memory (and crash on my machine)
    // so here we assume filling the input with 8 bytes

    fill_input(input=inputs, length=iterations / 8, iterator=0);

    let (res: Uint256) = cairo_keccak{keccak_ptr=keccak_ptr}(inputs=inputs, n_bytes=iterations);

    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);

    return ();
}

func fill_input(input: felt*, length: felt, iterator: felt) {
    if (iterator == length) {
        return ();
    }
    assert input[iterator] = 1;
    return fill_input(input, length, iterator + 1);
}
