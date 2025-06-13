%builtins output pedersen range_check ecdsa bitwise ec_op keccak poseidon range_check96 add_mod mul_mod

from starkware.cairo.common.cairo_secp.bigint3 import BigInt3
from starkware.cairo.common.cairo_secp.ec_point import EcPoint
from starkware.cairo.common.cairo_secp.ec import ec_double

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

    let gen_pt = EcPoint(
        BigInt3(0xe28d959f2815b16f81798, 0xa573a1c2c1c0a6ff36cb7, 0x79be667ef9dcbbac55a06),
        BigInt3(0x554199c47d08ffb10d4b8, 0x2ff0384422a3f45ed1229a, 0x483ada7726a3c4655da4f)
    );

    let final_pt = repeated_double(gen_pt, iterations);

    return ();
}

func repeated_double{range_check_ptr}(point: EcPoint, iterations: felt) -> EcPoint {
    alloc_locals;

    if (iterations == 0) {
        return point;
    }

    let (new_point) = ec_double(point);

    return repeated_double(new_point, iterations - 1);
}