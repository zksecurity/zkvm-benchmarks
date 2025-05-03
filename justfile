# Default recipe
default:
    just bench-all

# Build utilities
build-utils:
    cd utils && cargo build --release

# Bench all
bench-all fib_args sha_args sha_chain_args matmul_args: build-utils
    just bench-stone "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}"
    just bench-stwo "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}"
    just bench-jolt "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}"
    just bench-sp1 "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}"
    just bench-risczero "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}"
    just bench-openvm "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}"


#####
# jolt
#####

build-jolt:
    cd jolt && rustup install
    cd jolt && cargo build --release

# bench-all takes arguments for all benchmarks
bench-jolt fib_args sha_args sha_chain_args matmul_args: build-jolt
    just bench-jolt-fib "{{fib_args}}"
    just bench-jolt-sha2 "{{sha_args}}"
    just bench-jolt-sha2-chain "{{sha_chain_args}}"
    just bench-jolt-sha3 "{{sha_args}}"
    just bench-jolt-sha3-chain "{{sha_chain_args}}"

bench-jolt-fib fib_args:
    -for arg in {{fib_args}}; do ./bench_zkvm.sh "jolt" "fib" "$arg"; done

bench-jolt-sha2 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "jolt" "sha2" "$arg"; done

bench-jolt-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "jolt" "sha2-chain" "$arg"; done

bench-jolt-sha3 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "jolt" "sha3" "$arg"; done

bench-jolt-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "jolt" "sha3-chain" "$arg"; done


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

bench-sp1 fib_args sha_args sha_chain_args matmul_args: build-sp1
    just bench-sp1-fib "{{fib_args}}"
    just bench-sp1-sha2 "{{sha_args}}"
    just bench-sp1-sha2-chain "{{sha_chain_args}}"
    just bench-sp1-sha3 "{{sha_args}}"
    just bench-sp1-sha3-chain "{{sha_chain_args}}"
    just bench-sp1-mat-mul "{{matmul_args}}"
    just bench-sp1-sha2-precompile "{{sha_args}}"
    just bench-sp1-sha2-chain-precompile "{{sha_chain_args}}"
    just bench-sp1-sha3-precompile "{{sha_args}}"
    just bench-sp1-sha3-chain-precompile "{{sha_chain_args}}"

bench-sp1-fib fib_args:
    -for arg in {{fib_args}}; do ./bench_zkvm.sh "sp1" "fib" "$arg"; done

bench-sp1-sha2 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "sp1" "sha2" "$arg"; done

bench-sp1-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "sp1" "sha2-chain" "$arg"; done

bench-sp1-sha2-precompile sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "sp1" "sha2-precompile" "$arg"; done

bench-sp1-sha2-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "sp1" "sha2-chain-precompile" "$arg"; done

bench-sp1-sha3-precompile sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "sp1" "sha3-precompile" "$arg"; done

bench-sp1-sha3-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "sp1" "sha3-chain-precompile" "$arg"; done

bench-sp1-sha3 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "sp1" "sha3" "$arg"; done

bench-sp1-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "sp1" "sha3-chain" "$arg"; done

bench-sp1-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./bench_zkvm.sh "sp1" "mat-mul" "$arg"; done



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

bench-risczero fib_args sha_args sha_chain_args matmul_args: build-risczero
    just bench-risczero-fib "{{fib_args}}"
    just bench-risczero-sha2 "{{sha_args}}"
    just bench-risczero-sha2-chain "{{sha_chain_args}}"
    just bench-risczero-sha2-precompile "{{sha_args}}"
    just bench-risczero-sha2-chain-precompile "{{sha_chain_args}}"
    just bench-risczero-sha3 "{{sha_args}}"
    just bench-risczero-sha3-precompile "{{sha_args}}"
    just bench-risczero-sha3-chain "{{sha_chain_args}}"
    just bench-risczero-sha3-chain-precompile "{{sha_chain_args}}"
    just bench-risczero-mat-mul "{{matmul_args}}"

bench-risczero-fib fib_args:
    -for arg in {{fib_args}}; do ./bench_zkvm.sh "risczero" "fib" "$arg"; done

bench-risczero-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./bench_zkvm.sh "risczero" "mat-mul" "$arg"; done

bench-risczero-sha2 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "risczero" "sha2" "$arg"; done

bench-risczero-sha2-precompile sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "risczero" "sha2-precompile" "$arg"; done

bench-risczero-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "risczero" "sha2-chain" "$arg"; done

bench-risczero-sha2-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "risczero" "sha2-chain-precompile" "$arg"; done

bench-risczero-sha3 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "risczero" "sha3" "$arg"; done

bench-risczero-sha3-precompile sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "risczero" "sha3-precompile" "$arg"; done

bench-risczero-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "risczero" "sha3-chain" "$arg"; done

bench-risczero-sha3-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "risczero" "sha3-chain-precompile" "$arg"; done


#####
# Stone
#####

build-stone:
    cd stone/common && cargo build --release
    cd stone/fib && cargo build --release
    cd stone/sha3 && cargo build --release
    cd stone/sha3-chain && cargo build --release
    cd stone/sha3-builtin && cargo build --release
    cd stone/sha3-chain-builtin && cargo build --release
    cd stone/sha2 && cargo build --release
    cd stone/sha2-chain && cargo build --release
    cd stone/mat-mul && cargo build --release
    -just build-stone-steps

build-stone-steps:
	-cd stone && git clone https://github.com/lambdaclass/cairo-vm.git
	-cd stone/cairo-vm/cairo1-run && make deps

bench-stone fib_args sha_args sha_chain_args matmul_args: build-stone
    just bench-stone-fib "{{fib_args}}"
    just bench-stone-sha3 "{{sha_args}}"
    just bench-stone-sha3-chain "{{sha_chain_args}}"
    just bench-stone-sha3-builtin
    just bench-stone-sha3-chain-builtin
    just bench-stone-mat "{{matmul_args}}"
    just bench-stone-sha2 "{{sha_args}}"
    just bench-stone-sha2-chain "{{sha_chain_args}}"

bench-stone-fib fib_args:
    -for arg in {{fib_args}}; do ./bench_zkvm.sh "stone" "fib" "$arg"; done

bench-stone-mat matmul_args:
    -for arg in {{matmul_args}}; do ./bench_zkvm.sh "stone" "mat-mul" "$arg"; done

bench-stone-sha3 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "stone" "sha3" "$arg"; done

bench-stone-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "stone" "sha3-chain" "$arg"; done

# representing bytes 200, 400, 800, 1600, 3200
# as each iteration of the sha3 builtin processes 200 bytes
# let inputs = [1, 2, 4, 8, 16];
bench-stone-sha3-builtin:
    -for arg in 1 2 4 8 16; do ./bench_zkvm.sh "stone" "sha3-builtin" "$arg"; done

# to adapt to the 200 bytes per iteration of the sha3 builtin,
# the number of equivalent iterations is:
# 32 bytes * 4 = 128 bytes     → 128 / 200 = 0.64
# 32 bytes * 8 = 256 bytes     → 256 / 200 = 1.28
# 32 bytes * 16 = 512 bytes    → 512 / 200 = 2.56
# 32 bytes * 32 = 1024 bytes   → 1024 / 200 = 5.12
# 32 bytes * 64 = 2048 bytes   → 2048 / 200 = 10.24
# 32 bytes * 128 = 4096 bytes  → 4096 / 200 = 20.48
# 32 bytes * 256 = 8192 bytes  → 8192 / 200 = 40.96
# 32 bytes * 512 = 16384 bytes → 16384 / 200 = 81.92
# 32 bytes * 1024 = 32768 bytes → 32768 / 200 = 163.84
bench-stone-sha3-chain-builtin:
    -for arg in 1 3 5 10 20 40 80 160; do ./bench_zkvm.sh "stone" "sha3-chain-builtin" "$arg"; done

bench-stone-sha2 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "stone" "sha2" "$arg"; done

bench-stone-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "stone" "sha2-chain" "$arg"; done


#####
# Stwo
#####

build-stwo:
    cd stwo && cargo build --release
    cd stwo/fib && scarb build
    cd stwo/mat_mul && scarb build
    -cd stwo && git clone https://github.com/starkware-libs/stwo-cairo.git && cd stwo-cairo && git checkout 36092a6f4c145b71fc275e3712e8df4df50b5dc6
    cd stwo/stwo-cairo/stwo_cairo_prover && cargo build --release

bench-stwo fib_args sha_args sha_chain_args matmul_args: build-stwo
    just bench-stwo-fib "{{fib_args}}"
    just bench-stwo-sha2 "{{sha_args}}"
    just bench-stwo-sha2-chain "{{sha_chain_args}}"
    just bench-stwo-sha3 "{{sha_args}}"
    just bench-stwo-sha3-chain "{{sha_chain_args}}"
    just bench-stwo-mat-mul "{{matmul_args}}"

bench-stwo-fib fib_args:
    -for arg in {{fib_args}}; do ./bench_zkvm.sh "stwo" "fib" "$arg"; done

bench-stwo-sha2 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "stwo" "sha2" "$arg"; done

bench-stwo-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "stwo" "sha2-chain" "$arg"; done

bench-stwo-sha3 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "stwo" "sha3" "$arg"; done

bench-stwo-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "stwo" "sha3-chain" "$arg"; done

bench-stwo-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./bench_zkvm.sh "stwo" "mat-mul" "$arg"; done



#####
# openvm
#####

build-openvm:
    cd openvm && rustup install
    cd openvm && cargo build --release

bench-openvm fib_args sha_args sha_chain_args matmul_args: build-openvm
    just bench-openvm-fib "{{fib_args}}"
    just bench-openvm-sha2 "{{sha_args}}"
    just bench-openvm-sha2-chain "{{sha_chain_args}}"
    just bench-openvm-sha3 "{{sha_args}}"
    just bench-openvm-sha3-chain "{{sha_chain_args}}"
    just bench-openvm-sha2-precompile "{{sha_args}}"
    just bench-openvm-sha2-chain-precompile "{{sha_chain_args}}"
    just bench-openvm-sha3-precompile "{{sha_args}}"
    just bench-openvm-sha3-chain-precompile "{{sha_chain_args}}"
    just bench-openvm-mat-mul "{{matmul_args}}"

bench-openvm-fib fib_args:
    -for arg in {{fib_args}}; do ./bench_zkvm.sh "openvm" "fib" "$arg"; done

bench-openvm-sha2 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "openvm" "sha2" "$arg"; done

bench-openvm-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "openvm" "sha2-chain" "$arg"; done

bench-openvm-sha3 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "openvm" "sha3" "$arg"; done

bench-openvm-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "openvm" "sha3-chain" "$arg"; done

bench-openvm-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./bench_zkvm.sh "openvm" "mat-mul" "$arg"; done

bench-openvm-sha2-precompile sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "openvm" "sha2-precompile" "$arg"; done

bench-openvm-sha2-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "openvm" "sha2-chain-precompile" "$arg"; done

bench-openvm-sha3-precompile sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "openvm" "sha3-precompile" "$arg"; done

bench-openvm-sha3-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "openvm" "sha3-chain-precompile" "$arg"; done

