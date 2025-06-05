use core::keccak::compute_keccak_byte_array;

#[executable]
fn main() -> u256 {

    let data = "Hello";
    let hash = compute_keccak_byte_array(@data);
    hash

}