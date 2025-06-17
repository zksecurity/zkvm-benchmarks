%builtins output pedersen range_check ecdsa bitwise ec_op keccak poseidon range_check96 add_mod mul_mod

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

    let res = fib(0, 1, iterations);

    return ();
}

func fib(first_element: felt, second_element: felt, n: felt) -> felt {
    if (n == 1) {
        return second_element;
    }

    return fib(
        first_element=second_element, second_element=first_element + second_element, n=n - 1
    );
}