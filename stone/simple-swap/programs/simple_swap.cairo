// Reference https://github.com/avnu-labs/avnu-contracts-v2/blob/70dbb3ad6a0ce3fc9600420a7ca037030b054df0/src/exchange.cairo#L413

use array::ArrayTrait;
use core::felt252;
#[feature("corelib-internal-use")]
use core::integer::{u512, u256_wide_mul, u512_safe_div_rem_by_u256, u256_safe_divmod, u256_as_non_zero, u256_overflowing_add};
//use core::num::traits::Zero;
use core::option::{Option, OptionTrait};

fn main(input: Array<felt252>) -> Array<felt252> {
    let mut n = *input.at(0);

    //let zero_felt: felt252 = 0;

    while n != 0 {
        let (_token_from_used, _token_to_received) = simple_swap();
        //simple_swap();
        n = n - 1;
    };

    let mut output: Array<felt252> = ArrayTrait::new();
    n.serialize(ref output);
    output
}


fn simple_swap() -> (u256, u256) {
    let token_from_amount = 100_u256; // Initial Token A provided
    let token_from_max_amount = 500_u256; // Maximum Token A allowed
    let token_to_amount = 200_u256; // Desired Token B amount
    let target_fees_bps = 50_u256; // Fees in basis points (0.5%)

    // Step 1: Calculate fee
    let (fee_amount_target, overflows) = muldiv(token_to_amount, target_fees_bps.into(), 10000_u256, false);
    assert(overflows == false, 'Overflow: Invalid fee');

    // Step 2: Initialize variables
    let mut token_from_amount_used = token_from_amount;
    let mut remaining_token_from_amount = token_from_max_amount - token_from_amount;
    let mut token_to_amount_received = 0_u256;

    // Calculate missing Token B
    let token_to_missing_amount = token_to_amount + fee_amount_target - token_to_amount_received;

    // Calculate additional Token A needed
    let (token_from_amount_to_transfer, _overflows) = muldiv(token_from_amount_used, token_to_missing_amount, token_to_amount_received + 1, true);
    //assert(overflows == false, 'Overflow: swap iteration');
    //assert(token_from_amount_to_transfer <= remaining_token_from_amount, 'Insufficient token from amount');

    // Update state
    token_from_amount_used += token_from_amount_to_transfer;
    token_to_amount_received += token_to_missing_amount;
    remaining_token_from_amount -= token_from_amount_to_transfer;

    // Step 4: Return final results
    (token_from_amount_used, token_to_amount_received)

}

// Compute floor(x/z) OR ceil(x/z) depending on round_up
fn div(x: u256, z: u256, round_up: bool) -> u256 {
    let (quotient, remainder, _) = u256_safe_divmod(x, u256_as_non_zero(z));
    return if (!round_up || remainder.is_zero()) {
        quotient
    } else {
        quotient + 1_u256
    };
}

// Compute floor(x * y / z) OR ceil(x * y / z) without overflowing if the result fits within 256 bits
fn muldiv(x: u256, y: u256, z: u256, round_up: bool) -> (u256, bool) {
    let numerator = u256_wide_mul(x, y);

    if ((numerator.limb3 == 0) && (numerator.limb2 == 0)) {
        return (div(u256 { low: numerator.limb0, high: numerator.limb1 }, z, round_up), false);
    }

    let (quotient, remainder) = u512_safe_div_rem_by_u256(numerator, u256_as_non_zero(z));

    let overflows = (z <= u256 { low: numerator.limb2, high: numerator.limb3 });

    return if (!round_up || remainder.is_zero()) {
        (u256 { low: quotient.limb0, high: quotient.limb1 }, overflows)
    } else {
        let (sum, sum_overflows) = u256_overflowing_add(u256 { low: quotient.limb0, high: quotient.limb1 }, u256 { low: 1, high: 0 });
        (sum, sum_overflows || overflows)
    };
}
