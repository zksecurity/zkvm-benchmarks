%builtins range_check bitwise keccak

from starkware.cairo.common.builtin_keccak.keccak import keccak
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, KeccakBuiltin
from starkware.cairo.common.alloc import alloc

// For usage refer the following link:
// https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/builtin_keccak/keccak.cairo#L1-L11

// The main function now accepts a parameter `n` that indicates how many times to hash.
func main{range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*, keccak_ptr: KeccakBuiltin*}() {
    alloc_locals;

    local iterations;
    %{ ids.iterations = program_input['iterations'] %}

    let (inputs: felt*) = alloc();
    fill_input(input=inputs, length=iterations / 8, iterator=0);

    let res = keccak(inputs=inputs, n_bytes=iterations);

    return ();
}

func fill_input(input: felt*, length: felt, iterator: felt) {
    if (iterator == length) {
        return ();
    }
    assert input[iterator] = 1;
    return fill_input(input, length, iterator + 1);
}
