#![no_main]
sp1_zkvm::entrypoint!(main);

pub fn main() {
    let search_array: Vec<usize> = sp1_zkvm::io::read();

    let res = find(&search_array, search_array[0]).unwrap();
    assert_eq!(res, 0);

    sp1_zkvm::io::commit(&res);
}

fn find(search_array: &[usize], value: usize) -> Option<usize> {
    let mut left: usize = 0;
    let mut right: usize = search_array.len();

    while left < right {
        let mid = left + (right - left) / 2;
        let mid_value = search_array[mid];

        if mid_value == value {
            return Some(mid);
        } else if mid_value < value {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    None
}

