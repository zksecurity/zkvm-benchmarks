%builtins output pedersen range_check ecdsa bitwise ec_op keccak poseidon range_check96 add_mod mul_mod

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.memset import memset
from starkware.cairo.common.math import unsigned_div_rem

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

func fill_input(input: felt*, length: felt, iterator: felt) {
    if (iterator == length) {
        return ();
    }
    assert input[iterator] = 0x50505050; // 4 bytes
    return fill_input(input, length, iterator + 1);
}

func main{
    output_ptr,
    pedersen_ptr,
    range_check_ptr,
    ecdsa_ptr,
    bitwise_ptr,
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
    let (out_ptr: felt*) = alloc();

    fill_input(input=inputs, length=iterations / 4, iterator=0);

    blake_with_opcode(iterations / 4, inputs, out_ptr);

    return ();
}