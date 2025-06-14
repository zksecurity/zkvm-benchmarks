%builtins output pedersen range_check ecdsa bitwise ec_op keccak poseidon range_check96 add_mod mul_mod

from starkware.cairo.common.cairo_keccak.keccak import cairo_keccak, finalize_keccak
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc

// For usage refer the following link:
// https://github.com/starkware-libs/cairo-lang/blob/ab8be40403a7634ba296c467b26b8bd945ba5cfa/src/starkware/cairo/common/cairo_keccak/keccak.cairo#L1C1-L38C85

func main{
    output_ptr,
    pedersen_ptr,
    range_check_ptr,
    ecdsa_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    ec_op_ptr,
    keccak_ptr,
    poseidon_ptr,
    range_check96_ptr,
    add_mod_ptr,
    mul_mod_ptr,
}() {
    alloc_locals;

    local iterations;
    %{ ids.iterations = program_input['iterations'] %}

    let (inputs: felt*) = alloc();

    let n_bytes = 32;

    // each felt field has 251 bits, so it can hold 31 bytes
    // less input fields take much more memory (and crash on my machine)
    // so here we assume filling the input with 8 bytes
    fill_input(input=inputs, length=n_bytes / 8, iterator=0);

    let (hash_ptr: felt*) = alloc();
    let keccak_ptr_start = hash_ptr;

    let final_state = repeat_hash{keccak_ptr=hash_ptr}(inputs, iterations-1);

    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=hash_ptr);

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
func repeat_hash{range_check_ptr, bitwise_ptr: BitwiseBuiltin*, keccak_ptr: felt*}(inputs: felt*, iterations: felt) -> Uint256 {
    alloc_locals;

    if (iterations == 0) {
        let (res: Uint256) = cairo_keccak(inputs=inputs, n_bytes=32);
        return res;
    }

    let (res: Uint256) = cairo_keccak(inputs=inputs, n_bytes=32);
    return repeat_hash(inputs, iterations - 1);
}
