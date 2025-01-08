use array::ArrayTrait;

fn main(input: Array<felt252>) -> Array<felt252> {
    let mut input = input.span();
    let search_array: Array<usize> = Serde::deserialize(ref input).unwrap();

    let res = find(@search_array, *search_array.at(0)).unwrap();
    assert(res == 0, 'Index should be 0');

    let mut output: Array<felt252> = ArrayTrait::new();
    res.serialize(ref output);
    output
}

pub fn find(search_array: @Array<usize>, value: usize) -> Option<usize> {
    let mut left: usize = 0;
    let mut right: usize = search_array.len();
    let mut result: Option<usize> = Option::None;

    loop {
        if left >= right {
            break;
        }

        let mid = left + (right - left) / 2;
        let mid_value = *search_array[mid];

        if mid_value == value {
            result = Option::Some(mid);
            break;
        } else if mid_value < value {
            left = mid + 1;
        } else {
            right = mid;
        }
    };

    result
}
 