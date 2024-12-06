%builtins keccak
from starkware.cairo.common.cairo_builtins import KeccakBuiltin
from starkware.cairo.common.keccak_state import KeccakBuiltinState

func main{keccak_ptr: KeccakBuiltin*}() {
    assert keccak_ptr[0].input = KeccakBuiltinState(1, 2, 3, 4, 5, 6, 7, 8);
    let result = keccak_ptr[0].output;
    let keccak_ptr = keccak_ptr + KeccakBuiltin.SIZE;
    return ();
}