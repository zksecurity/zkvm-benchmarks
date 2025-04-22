# # Define variables
# FIB_ARGS := "5000 10000 50000 100000 500000 1000000"
# EC_ARGS := "8 16 32 64 128"
# SHA_ARGS := "256 512 1024 2048 4096"
# SHA_CHAIN_ARGS := "230 460 920 1840 3680"
# MATMUL_ARGS := "10 20 40 60"

FIB_ARGS := "5 10"
EC_ARGS := "4 8"
SHA_ARGS := "32 64"
BINARY_SEARCH_ARGS := "8 16"
SHA_CHAIN_ARGS := "8 16"
MATMUL_ARGS := "10 20"

# Default recipe
default:
    just bench-all

# Build utilities
build-utils:
    cd utils && cargo build --release

# Bench all
bench-all: build-utils
    just bench-openvm
    just bench-stone
    just bench-stwo
    just bench-jolt
    just bench-sp1
    just bench-risczero


#####
# jolt
#####

build-jolt:
    cd jolt && rustup install
    cd jolt && cargo build --release

bench-jolt: build-jolt
    just bench-jolt-fib
    just bench-jolt-sha2
    # just bench-jolt-sha2-chain
    just bench-jolt-sha3
    just bench-jolt-sha3-chain
    # just bench-jolt-mat-mul
    # just bench-jolt-ec


bench-jolt-fib:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "jolt" "fib" "$arg"; done

bench-jolt-ec:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "jolt" "ec" "$arg"; done

bench-jolt-sha2:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "jolt" "sha2" "$arg"; done

bench-jolt-sha2-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "jolt" "sha2-chain" "$arg"; done

bench-jolt-sha3:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "jolt" "sha3" "$arg"; done

bench-jolt-sha3-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "jolt" "sha3-chain" "$arg"; done

bench-jolt-mat-mul:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "jolt" "mat-mul" "$arg"; done


#####
# sp1
#####

build-sp1:
	cd sp1/fib && cargo prove build
	cd sp1/sha2-chain && cargo prove build
	cd sp1/sha3-chain && cargo prove build
	cd sp1/sha2 && cargo prove build
	cd sp1/sha3 && cargo prove build
	cd sp1/mat-mul && cargo prove build
	cd sp1/sha2-precompile && cargo prove build
	cd sp1/sha2-chain-precompile && cargo prove build
	cd sp1/sha3-precompile && cargo prove build
	cd sp1/sha3-chain-precompile && cargo prove build
	cd sp1/ec && cargo prove build
	cd sp1/ec-precompile && cargo prove build
	cd sp1 && cargo build --release

bench-sp1: build-sp1
    just bench-sp1-fib
    just bench-sp1-sha2
    # just bench-sp1-sha2-chain
    just bench-sp1-sha3
    just bench-sp1-sha3-chain
    just bench-sp1-mat-mul
    just bench-sp1-sha2-precompile
    just bench-sp1-sha3-precompile
    # just bench-sp1-sha2-chain-precompile
    just bench-sp1-sha3-chain-precompile
    # just bench-sp1-ec
    # just bench-sp1-ec-precompile

bench-sp1-fib:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "sp1" "fib" "$arg"; done

bench-sp1-ec:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "sp1" "ec" "$arg"; done

bench-sp1-ec-precompile:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "sp1" "ec-precompile" "$arg"; done

bench-sp1-sha2:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "sp1" "sha2" "$arg"; done

bench-sp1-sha2-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "sp1" "sha2-chain" "$arg"; done

bench-sp1-sha2-precompile:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "sp1" "sha2-precompile" "$arg"; done

bench-sp1-sha2-chain-precompile:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "sp1" "sha2-chain-precompile" "$arg"; done

bench-sp1-sha3-precompile:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "sp1" "sha3-precompile" "$arg"; done

bench-sp1-sha3-chain-precompile:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "sp1" "sha3-chain-precompile" "$arg"; done

bench-sp1-sha3:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "sp1" "sha3" "$arg"; done

bench-sp1-sha3-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "sp1" "sha3-chain" "$arg"; done

bench-sp1-mat-mul:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "sp1" "mat-mul" "$arg"; done


#####
# risczero
#####

build-risczero:
    cd risczero/fib && cargo build --release
    cd risczero/sha2 && cargo build --release
    cd risczero/sha2-precompile && cargo build --release
    cd risczero/sha3 && cargo build --release
    cd risczero/sha3-precompile && cargo build --release
    cd risczero/sha2-chain && cargo build --release
    cd risczero/sha2-chain-precompile && cargo build --release
    cd risczero/sha3-chain && cargo build --release
    cd risczero/sha3-chain-precompile && cargo build --release
    cd risczero/ec && cargo build --release
    cd risczero/ec-precompile && cargo build --release    
    cd risczero/mat-mul && cargo build --release

bench-risczero: build-risczero
    just bench-risczero-fib
    just bench-risczero-sha2
    just bench-risczero-sha2-precompile
    just bench-risczero-sha3
    just bench-risczero-sha3-precompile
    # just bench-risczero-sha2-chain
    # just bench-risczero-sha2-chain-precompile
    just bench-risczero-sha3-chain
    just bench-risczero-sha3-chain-precompile
    # just bench-risczero-ec
    # just bench-risczero-ec-precompile
    just bench-risczero-mat-mul

bench-risczero-fib:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "risczero" "fib" "$arg"; done

bench-risczero-ec:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "risczero" "ec" "$arg"; done

bench-risczero-ec-precompile:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "risczero" "ec-precompile" "$arg"; done

bench-risczero-mat-mul:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "risczero" "mat-mul" "$arg"; done

bench-risczero-sha2:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "risczero" "sha2" "$arg"; done

bench-risczero-sha2-precompile:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "risczero" "sha2-precompile" "$arg"; done

bench-risczero-sha2-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "risczero" "sha2-chain" "$arg"; done

bench-risczero-sha2-chain-precompile:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "risczero" "sha2-chain-precompile" "$arg"; done

bench-risczero-sha3:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "risczero" "sha3" "$arg"; done

bench-risczero-sha3-precompile:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "risczero" "sha3-precompile" "$arg"; done

bench-risczero-sha3-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "risczero" "sha3-chain" "$arg"; done

bench-risczero-sha3-chain-precompile:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "risczero" "sha3-chain-precompile" "$arg"; done


#####
# Stone
#####

build-stone:
    cd stone/common && cargo build --release
    cd stone/fib && cargo build --release
    cd stone/sha3 && cargo build --release
    cd stone/sha3-builtin && cargo build --release
    cd stone/sha3-chain-builtin && cargo build --release
    cd stone/sha2 && cargo build --release
    cd stone/sha2-chain && cargo build --release
    cd stone/mat-mul && cargo build --release
    -just build-stone-steps

build-stone-steps:
	-cd stone && git clone https://github.com/lambdaclass/cairo-vm.git
	-cd stone/cairo-vm/cairo1-run && make deps

bench-stone: build-stone
    just bench-stone-fib
    just bench-stone-sha3
    just bench-stone-sha3-builtin
    just bench-stone-sha3-chain-builtin
    just bench-stone-mat
    just bench-stone-sha2
    # just bench-stone-sha2-chain

bench-stone-fib:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "stone" "fib" "$arg"; done

bench-stone-mat:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "stone" "mat-mul" "$arg"; done

bench-stone-sha3:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stone" "sha3" "$arg"; done

# representing bytes 200, 400, 1000, 2000
# as each iteration of the sha3 builtin processes 200 bytes
# let inputs = [1, 2, 5, 10];
bench-stone-sha3-builtin:
    -for arg in 1 2 5 10; do ./bench_zkvm.sh "stone" "sha3-builtin" "$arg"; done

# other programs use:
# 32 bytes * 230 = 7360 bytes
# 32 bytes * 460 = 14720 bytes
# 32 bytes * 920 = 29440 bytes
# 32 bytes * 1840 = 58880 bytes
# 32 bytes * 3680 = 117760 bytes
# to adapt to the 200 bytes per iteration of the sha3 builtin,
# the number of equivalent iterations is:
# 7360 / 200 = 36.8
# 14720 / 200 = 73.6
# 29440 / 200 = 147.2
# 58880 / 200 = 294.4
# 117760 / 200 = 588.8
bench-stone-sha3-chain-builtin:
    -for arg in 37 74 148 295 589; do ./bench_zkvm.sh "stone" "sha3-chain-builtin" "$arg"; done

bench-stone-sha2:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stone" "sha2" "$arg"; done

bench-stone-sha2-chain:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stone" "sha2-chain" "$arg"; done


#####
# Stwo
#####

build-stwo:
    cd stwo && cargo build --release
    cd stwo/fib && scarb build
    cd stwo/mat_mul && scarb build
    -cd stwo && git clone https://github.com/starkware-libs/stwo-cairo.git && cd stwo-cairo && git checkout 36092a6f4c145b71fc275e3712e8df4df50b5dc6
    cd stwo/stwo-cairo/stwo_cairo_prover && cargo build --release

bench-stwo:
    just bench-stwo-fib
    just bench-stwo-sha2
    just bench-stwo-sha3
    just bench-stwo-sha3-chain
    # just bench-stwo-sha2-chain
    just bench-stwo-mat-mul

bench-stwo-fib:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "stwo" "fib" "$arg"; done

bench-stwo-sha2:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stwo" "sha2" "$arg"; done

bench-stwo-sha3:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stwo" "sha3" "$arg"; done

bench-stwo-sha2-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "stwo" "sha2-chain" "$arg"; done

bench-stwo-sha3-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "stwo" "sha3-chain" "$arg"; done

bench-stwo-mat-mul:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "stwo" "mat-mul" "$arg"; done


#####
# openvm
#####

build-openvm:
    cd openvm && rustup install
    cd openvm && cargo build --release

bench-openvm:
    just bench-openvm-fib
    just bench-openvm-sha2
    # just bench-openvm-sha2-chain
    just bench-openvm-sha3
    just bench-openvm-sha3-chain
    just bench-openvm-sha2-precompile
    # just bench-openvm-sha2-chain-precompile
    just bench-openvm-sha3-precompile
    just bench-openvm-sha3-chain-precompile
    just bench-openvm-mat-mul

bench-openvm-fib:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "openvm" "fib" "$arg"; done

bench-openvm-sha2:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "openvm" "sha2" "$arg"; done

bench-openvm-sha2-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "openvm" "sha2-chain" "$arg"; done

bench-openvm-sha3:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "openvm" "sha3" "$arg"; done

bench-openvm-sha3-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "openvm" "sha3-chain" "$arg"; done

bench-openvm-mat-mul:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "openvm" "mat-mul" "$arg"; done

bench-openvm-sha2-precompile:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "openvm" "sha2-precompile" "$arg"; done

bench-openvm-sha2-chain-precompile:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "openvm" "sha2-chain-precompile" "$arg"; done

bench-openvm-sha3-precompile:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "openvm" "sha3-precompile" "$arg"; done

bench-openvm-sha3-chain-precompile:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "openvm" "sha3-chain-precompile" "$arg"; done
