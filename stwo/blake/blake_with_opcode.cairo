%builtins output pedersen range_check ecdsa bitwise ec_op keccak poseidon range_check96 add_mod mul_mod

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_blake2s.blake2s import (
    blake2s_as_words,
    finalize_blake2s,
)
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.memset import memset
from starkware.cairo.common.math import unsigned_div_rem

// Takes an array of `packed_values_len` felts at `packed_values` and unpacks it into an array of
// u32s at `unpacked_u32s` in the following way:
//  * If a felt is less than 2^63, it's unpacked to 2 felts, each representing 32 bits.
//  * Otherwise, it's unpacked into 8 felts, each under 2^32, where the most significant
//    limb has its MSB set (Note that the prime is less than 2^255 so the MSB could not be
//    set prior to this intervention).
// All 32-bit limbs are arranged in big-endian order.
// Returns the size of the unpacked array in felts.
// Assumes:
//  * All output felts in `upnacked_u32s` are extrenally verified to be in [0, 2^32).
// Note: This function can nondeterministically choose between several encodings of felts,
//      x < PRIME can be encoded as x + PRIME, x + 2 * PRIME, etc. The canonical encoding is
//      given when x < PRIME.
// TODO(alont): Write custom hints and integrate with VM.
// TODO(alont): Consider adding cases for 1 u32 (small immediates, including negatives)
//      and 3 u32s (extended opcodes).
// TODO(alont): Consider unrolling this loop to avoid state copy overhead.
func unpack_u32s{range_check_ptr: felt}(
    packed_values_len: felt, packed_values: felt*, unpacked_u32s: felt*
) -> felt {
    alloc_locals;

    local U63_MAX = 2 ** 63 - 1;
    local EXP31 = 2 ** 31;
    local end = cast(packed_values, felt) + packed_values_len;

    %{
        offset = 0
        for i in range(ids.packed_values_len):
            val = (memory[ids.packed_values + i] % PRIME)
            val_len = 2 if val < 2**63 else 8
            if val_len == 8:
                val += 2**255
            for i in range(val_len - 1, -1, -1):
                val, memory[ids.unpacked_u32s + offset + i] = divmod(val, 2**32)
            assert val == 0
            offset += val_len
    %}
    tempvar out = unpacked_u32s;
    tempvar packed_values = packed_values;
    tempvar range_check_ptr = range_check_ptr;

    loop:
    // Guess if number is small or big.
    if (nondet %{ (ids.end != ids.packed_values) and (memory[ids.packed_values] < 2**63) %} != 0) {
        // Unpack small felt.

        tempvar current_val = packed_values[0];
        // Assert that the value is in [0, 2^63).
        assert [range_check_ptr] = U63_MAX - current_val;
        // Assert that the limbs represent the number.
        assert current_val = out[1] + 2 ** 32 * out[0];

        tempvar out = &out[2];
        tempvar packed_values = &packed_values[1];
        tempvar range_check_ptr = range_check_ptr + 1;
        jmp loop;
    }

    if (end - cast(packed_values, felt) == 0) {
        return out - unpacked_u32s;
    }

    // Handle big felt.
    // Assert that the top limb is over 2^31, as its MSB is artificially set for encoding.
    tempvar raw_out_0 = out[0] - EXP31;
    assert [range_check_ptr] = raw_out_0;
    // Assert that the limbs represent the number. Set the MSB of the most significant limb.
    assert packed_values[0] = (
        (out[7] + (2 ** 32 * out[6])) +
        2 ** (32 * 2) * (out[5] + 2 ** 32 * out[4]) +
        2 ** (32 * 4) * (out[3] + 2 ** 32 * out[2]) +
        2 ** (32 * 6) * (out[1] + 2 ** 32 * raw_out_0)
    );

    tempvar out = &out[8];
    tempvar packed_values = &packed_values[1];
    tempvar range_check_ptr = range_check_ptr + 1;
    jmp loop;
}

const OP1_AP = 4;
const BLAKE2S_OPCODE_EXT = 1;
const BLAKE2S_FINALIZE_OPCODE_EXT = 2;
const BLAKE2S_AP_FLAGS = OP1_AP * (2 ** 2);

const OFF_MINUS_1 = 2 ** 15 - 1;
const OFF_MINUS_2 = 2 ** 15 - 2;
const OFF_MINUS_3 = 2 ** 15 - 3;
const OFF_MINUS_4 = 2 ** 15 - 4;

const COUNTER_OFFSET = 1;
const STATE_OFFSET = 2 ** 16;
const MESSAGE_OFFSET = 2 ** 32;
const FLAGS_OFFSET = 2 ** 48;
const OPCODE_EXT_OFFSET = 2 ** 63;

const BLAKE2S_INSTRUCTION = OFF_MINUS_1 * COUNTER_OFFSET + OFF_MINUS_4 * STATE_OFFSET +
    OFF_MINUS_3 * MESSAGE_OFFSET + BLAKE2S_AP_FLAGS * FLAGS_OFFSET + BLAKE2S_OPCODE_EXT *
    OPCODE_EXT_OFFSET;
const BLAKE2S_FINALIZE_INSTRUCTION = OFF_MINUS_1 * COUNTER_OFFSET + OFF_MINUS_3 * STATE_OFFSET +
    OFF_MINUS_2 * MESSAGE_OFFSET + BLAKE2S_AP_FLAGS * FLAGS_OFFSET + BLAKE2S_FINALIZE_OPCODE_EXT *
    OPCODE_EXT_OFFSET;

// Computes blake2s of `input` of size `len` felts, representing 32 bits each.
// Note: this function guarantees that len > 0.
func blake_with_opcode{range_check_ptr}(len: felt, data: felt*, out: felt*) {
    alloc_locals;

    let (local state: felt*) = alloc();
    assert state[0] = 0x6B08E647;  // IV[0] ^ 0x01010020 (config: no key, 32 bytes output).
    assert state[1] = 0xBB67AE85;
    assert state[2] = 0x3C6EF372;
    assert state[3] = 0xA54FF53A;
    assert state[4] = 0x510E527F;
    assert state[5] = 0x9B05688C;
    assert state[6] = 0x1F83D9AB;
    assert state[7] = 0x5BE0CD19;

    // Express the length in bytes, subtract the remainder for finalize.
    let (_, rem) = unsigned_div_rem(len - 1, 16);
    local rem = rem + 1;
    local len_in_bytes = (len - rem) * 4;

    local range_check_ptr = range_check_ptr;

    // Copy remaining data and pad with zeroes.
    let (local final_data: felt*) = alloc();
    memcpy(final_data, &data[len - rem], rem);
    memset(&final_data[rem], 0, 16 - rem);

    tempvar counter = 0;
    tempvar state = state;
    tempvar data = data;

    loop:
    if (counter - len_in_bytes == 0) {
        // Add remainder bytes to counter.
        tempvar counter = counter + (rem * 4);
        [ap] = state, ap++;
        [ap] = final_data, ap++;
        [ap] = counter, ap++;
        [ap] = out;
        dw BLAKE2S_FINALIZE_INSTRUCTION;
        // Increment AP after blake opcode.
        ap += 1;

        let range_check_ptr = [fp + 3];
        return ();
    }

    tempvar counter = counter + 64;

    // Blake output pointer / the next state.
    [ap] = &state[8];
    dw BLAKE2S_INSTRUCTION;

    let state = cast([ap - 4], felt*);
    let data = cast([ap - 3], felt*);

    // Increment AP after blake opcode.
    ap += 1;

    tempvar data = data + 16;
    jmp loop;
}

// Repeats the block `src` `n` times, each time writing it to `dst`.
func repeat(dst: felt*, src: felt*, n: felt, block_size: felt) {
    if (n == 0) {
        return ();
    }
    memcpy(dst, src, block_size);
    return repeat(dst + block_size, src, n - 1, block_size);
}

func fill_input(input: felt*, length: felt, iterator: felt) {
    if (iterator == length) {
        return ();
    }
    assert input[iterator] = 0x50505050; // 4 bytes
    return fill_input(input, length, iterator + 1);
}

func main{
    output_ptr: felt*,
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