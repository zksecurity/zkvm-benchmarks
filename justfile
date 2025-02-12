# Define variables
FIB_ARGS: "100 1000 10000 50000"
ECADD_ARGS: "2 5 10 20"
SHA_ARGS: "32 256 512 1024 2048"
BINARY_SEARCH_ARGS: "128 256 512 1024 2048"
SHA_CHAIN_ARGS: "230 460 920 1840 3680"
MATMUL_ARGS: "10 20 40 60"

# Default recipe
default:
    @just bench-all

# Build utilities
build-utils:
    cd utils && cargo build

# Bench all
bench-all:
    just build-utils
    just bench-stone

# Bench stone
bench-stone:
    just build-stone
    just bench-stone-time!
    just bench-stone-mem!

bench-stone-time:
    just bench-stone-fib-time!
    just bench-stone-keccak-time!
    just bench-stone-keccak-builtin-time!
    just bench-stone-keccak-builtin-chain-time!
    just bench-stone-mat-time!
    just bench-stone-binary-search-time!
    just bench-stone-sha256-time!
    just bench-stone-sha256-chain-time!

bench-stone-mem:
    just bench-stone-fib-mem!
    just bench-stone-keccak-mem!
    just bench-stone-keccak-builtin-mem!
    just bench-stone-keccak-builtin-chain-mem!
    just bench-stone-mat-mem!
    just bench-stone-binary-search-mem!
    just bench-stone-sha256-mem!
    just bench-stone-sha256-chain-mem!

# Build stone
build-stone:
    cd stone/common && cargo build --release
    cd stone/binary-search && cargo build --release
    cd stone/fibonacci && cargo build --release
    cd stone/keccak && cargo build --release
    cd stone/keccak-builtin && cargo build --release
    cd stone/keccak-builtin-chain && cargo build --release
    cd stone/sha256 && cargo build --release
    cd stone/sha256-chain && cargo build --release
    cd stone/mat-mul && cargo build --release

# Bench specific components
bench-stone-fib-time:
    for arg in {{FIB_ARGS}}; do
        cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $$arg!
    done

bench-stone-fib-mem:
    for arg in {{FIB_ARGS}}; do
        cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $$arg --bench-mem!
    done

bench-stone-mat-time:
    for arg in {{MATMUL_ARGS}}; do
        cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg $$arg!
    done

bench-stone-mat-mem:
    for arg in {{MATMUL_ARGS}}; do
        cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg $$arg --bench-mem!
    done

bench-stone-keccak-time:
    for arg in {{SHA_ARGS}}; do
        cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $$arg!
    done

bench-stone-keccak-mem:
    for arg in {{SHA_ARGS}}; do
        cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $$arg --bench-mem!
    done

bench-stone-keccak-builtin-time:
    for arg in 1 2 5 10; do
        cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg $$arg!
    done

bench-stone-keccak-builtin-mem:
    for arg in 1 2 5 10; do
        cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg $$arg --bench-mem!
    done

bench-stone-keccak-builtin-chain-time:
    for arg in 37 74 148 295 589; do
        cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg $$arg!
    done

bench-stone-keccak-builtin-chain-mem:
    for arg in 37 74 148 295 589; do
        cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg $$arg --bench-mem!
    done

bench-stone-sha256-time:
    for arg in {{SHA_ARGS}}; do
        cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $$arg!
    done

bench-stone-sha256-mem:
    for arg in {{SHA_ARGS}}; do
        cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $$arg --bench-mem!
    done
