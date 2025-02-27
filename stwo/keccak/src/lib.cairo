use core::byte_array;
use core::keccak::compute_keccak_byte_array;
use core::sha256::compute_sha256_byte_array;

#[executable]
fn main(input: u32) -> [u32; 8] {
    // let mut input_bytes: ByteArray = "A";
    // let hash = compute_keccak_byte_array(@input_bytes);
    // hash

    let data = "Hello";
    let hash = compute_sha256_byte_array(@data);
    hash

}
