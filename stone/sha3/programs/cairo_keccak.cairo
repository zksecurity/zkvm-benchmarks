%builtins output pedersen range_check ecdsa bitwise ec_op keccak poseidon range_check96 add_mod mul_mod

from starkware.cairo.common.cairo_keccak.keccak import cairo_keccak, finalize_keccak
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

    // because the stone-cli only expose the input keyed by 'iterations'
    // here variable is called iterations to represent n_bytes
    local iterations;
    %{ ids.iterations = program_input['iterations'] %}

    let (hash_ptr: felt*) = alloc();
    let keccak_ptr_start = hash_ptr;

    let (inputs: felt*) = alloc();

    // each felt field has 251 bits, so it can hold 31 bytes
    // less input fields take much more memory (and crash on my machine)
    // so here we assume filling the input with 8 bytes

    fill_input(input=inputs, length=iterations / 8, iterator=0);

    let res = cairo_keccak{keccak_ptr=hash_ptr}(inputs=inputs, n_bytes=iterations);

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
