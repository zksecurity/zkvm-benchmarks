%builtins output range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_blake2s.blake2s import (
    blake2s_as_words,
    blake_with_opcode,
    finalize_blake2s,
    unpack_u32s,
)
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.memcpy import memcpy

// Repeats the block `src` `n` times, each time writing it to `dst`.
func repeat(dst: felt*, src: felt*, n: felt, block_size: felt) {
    if (n == 0) {
        return ();
    }
    memcpy(dst, src, block_size);
    return repeat(dst + block_size, src, n - 1, block_size);
}

func main{output_ptr: felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() {
    // TODO(yuval): Get this test or similar to run in CI.
    alloc_locals;

    let (local data: felt*) = alloc();
    let (local packed: felt*) = alloc();

    assert packed[0] = 0x83254989;
    assert packed[1] = 0x126476347687378278789747389723894789;
    assert packed[2] = 0x12345678;
    assert packed[3] = 0x327823874823748237847238748;
    assert packed[4] = 0x093408589435923859589823999;
    assert packed[5] = 0x9874a37;
    assert packed[6] = 0x89923473;
    assert packed[7] = 0x892348599834983967723875388;
    assert packed[8] = 0x892348599834983967723875388;
    assert packed[9] = 0x8923485a9834b83967723875388;
    assert packed[10] = 0x8923425998349839f7728875388;

    let len = unpack_u32s(packed_values_len=11, packed_values=packed, unpacked_u32s=data);
    tempvar reps = 16;

    repeat(data, data, reps, len);

    blake_with_opcode(len * (reps - 1), data, output_ptr);

    // Check the output against the cairo implementation.
    let blake2s_ptr: felt* = alloc();
    local blake2s_ptr_start: felt* = blake2s_ptr;
    with blake2s_ptr {
        let output: felt* = blake2s_as_words(data, (len * (reps - 1)) * 4);
    }
    finalize_blake2s(blake2s_ptr_start=blake2s_ptr_start, blake2s_ptr_end=blake2s_ptr);
    memcpy(output_ptr, output, 8);

    let output_ptr = &output_ptr[8];
    return ();
}