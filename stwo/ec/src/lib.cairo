use core::circuit::u384;
use garaga::definitions::G1Point;
use garaga::ec_ops::ec_safe_add;

#[executable]
fn main(mut n: u64) {

    // x-coordinate of generater of SECP256K1
    // 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
    let g_x = u384 {
        limb0: 0x2dce28d959f2815b16f81798,
        limb1: 0x55a06295ce870b07029bfcdb,
        limb2: 0x79be667ef9dcbbac,
        limb3: 0,
    };

    // y-coordinate of generater of SECP256K1
    // 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
    let g_y = u384 {
        limb0: 0xa68554199c47d08ffb10d4b8,
        limb1: 0x5da4fbfc0e1108a8fd17b448,
        limb2: 0x483ada7726a3c465,
        limb3: 0,
    };

    // Generator point
    let gen = G1Point {
        x: g_x,
        y: g_y,
    };

    loop {
        if n == 0 {
            break;
        }

        // curve_index 2: SECP256K1
        // https://github.com/keep-starknet-strange/garaga/blob/f5921e0f7e69f474ee0a88b6ecfb52252fc7cc3d/src/src/definitions.cairo#L633
        let _ = ec_safe_add(gen, gen, 2);

        n = n - 1;
        
    };

}
