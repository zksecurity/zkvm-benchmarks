%builtins output pedersen range_check ecdsa bitwise ec_op keccak poseidon range_check96 add_mod mul_mod

from starkware.cairo.common.alloc import alloc

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

    let size = iterations;

    // Allocate and fill matrix a with 1s
    let (a_ptr: felt*) = alloc();
    fill_matrix(a_ptr, size, 1, 0);

    // Allocate and fill matrix b with 2s
    let (b_ptr: felt*) = alloc();
    fill_matrix(b_ptr, size, 2, 0);

    // Allocate result matrix
    let (res_ptr: felt*) = alloc();

    // Perform matrix multiplication
    matrix_mul(a_ptr, b_ptr, res_ptr, size);

    return ();
}

func fill_matrix(ptr: felt*, size: felt, value: felt, i: felt) {
    if (i == size * size) {
        return ();
    }
    assert ptr[i] = value;
    return fill_matrix(ptr, size, value, i + 1);
}

func matrix_mul(a_ptr: felt*, b_ptr: felt*, res_ptr: felt*, size: felt) {
    return mul_rows(a_ptr, b_ptr, res_ptr, size, 0);
}

func mul_rows(a_ptr: felt*, b_ptr: felt*, res_ptr: felt*, size: felt, i: felt) {
    if (i == size) {
        return ();
    }
    mul_cols(a_ptr, b_ptr, res_ptr, size, i, 0);
    return mul_rows(a_ptr, b_ptr, res_ptr, size, i + 1);
}

func mul_cols(a_ptr: felt*, b_ptr: felt*, res_ptr: felt*, size: felt, i: felt, j: felt) {
    if (j == size) {
        return ();
    }
    let (sum) = dot_product(a_ptr, b_ptr, size, i, j, 0, 0);
    assert res_ptr[i * size + j] = sum;
    return mul_cols(a_ptr, b_ptr, res_ptr, size, i, j + 1);
}

func dot_product(a_ptr: felt*, b_ptr: felt*, size: felt, i: felt, j: felt, k: felt, acc: felt) -> (sum: felt) {
    if (k == size) {
        return (acc,);
    }
    let a_val = a_ptr[i * size + k];
    let b_val = b_ptr[k * size + j];
    let acc_new = acc + a_val * b_val;
    return dot_product(a_ptr, b_ptr, size, i, j, k + 1, acc_new);
}
