#![cfg_attr(feature = "guest", no_std)]
#![no_main]

#[jolt::provable]
fn find(search_array: &[u8]) -> u32 {
    let value = search_array[0];

    let mut left: usize = 0;
    let mut right: usize = search_array.len();

    let mut res = u32::MAX;

    while left < right {
        let mid = left + (right - left) / 2;
        let mid_value = search_array[mid];

        if mid_value == value {
            res = mid as u32;
            break;
        } else if mid_value < value {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    assert_eq!(res, 0);
    res
}

