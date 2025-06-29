set export
PATH := "$HOME/.cargo/bin:$HOME/.risc0/bin:$HOME/.sp1/bin:$HOME/.local/bin:$PATH"

FIB_ARG_LOCAL := "4096 8192 16384 32768 65536 131072"
SHA2_ARG_LOCAL := "256 512 1024 2048 4096 8192"
SHA2_CHAIN_ARG_LOCAL := "64 128 256 512 1024 2048 4096"
SHA3_ARG_LOCAL := "256 512 1024 2048 4096 8192"
SHA3_CHAIN_ARG_LOCAL := "64 128 256 512 1024 2048 4096"
MATMUL_ARG_LOCAL := "4 8 16 32 64"
EC_ARG_LOCAL := "16 32 64 128 256 512 1024 2048"

# Default recipe
default:
    just bench-local

# Check Setup
check-setup:
    ./scripts/check_setup.sh

# Capture machine information
machine-info:
    ./scripts/machine_info.sh

# Build utilities
build-utils:
    cd utils && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

# Bench local
bench-local: build-utils machine-info check-setup
    just bench-stwo      {{FIB_ARG_LOCAL}} {{SHA2_ARG_LOCAL}} {{SHA2_CHAIN_ARG_LOCAL}} {{SHA3_ARG_LOCAL}} {{SHA3_CHAIN_ARG_LOCAL}} {{MATMUL_ARG_LOCAL}} {{EC_ARG_LOCAL}}
    just bench-jolt      {{FIB_ARG_LOCAL}} {{SHA2_ARG_LOCAL}} {{SHA2_CHAIN_ARG_LOCAL}} {{SHA3_ARG_LOCAL}} {{SHA3_CHAIN_ARG_LOCAL}} {{MATMUL_ARG_LOCAL}} {{EC_ARG_LOCAL}}
    just bench-sp1       {{FIB_ARG_LOCAL}} {{SHA2_ARG_LOCAL}} {{SHA2_CHAIN_ARG_LOCAL}} {{SHA3_ARG_LOCAL}} {{SHA3_CHAIN_ARG_LOCAL}} {{MATMUL_ARG_LOCAL}} {{EC_ARG_LOCAL}}
    just bench-risczero  {{FIB_ARG_LOCAL}} {{SHA2_ARG_LOCAL}} {{SHA2_CHAIN_ARG_LOCAL}} {{SHA3_ARG_LOCAL}} {{SHA3_CHAIN_ARG_LOCAL}} {{MATMUL_ARG_LOCAL}} {{EC_ARG_LOCAL}}
    just bench-openvm    {{FIB_ARG_LOCAL}} {{SHA2_ARG_LOCAL}} {{SHA2_CHAIN_ARG_LOCAL}} {{SHA3_ARG_LOCAL}} {{SHA3_CHAIN_ARG_LOCAL}} {{MATMUL_ARG_LOCAL}} {{EC_ARG_LOCAL}}


#####
# jolt
#####

build-jolt:
    cd jolt && rustup install
    cd jolt && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

# bench-all takes arguments for all benchmarks
bench-jolt fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: check-setup build-jolt
    just bench-jolt-fib "{{fib_args}}"
    just bench-jolt-sha2 "{{sha2_args}}"
    just bench-jolt-sha2-chain "{{sha2_chain_args}}"
    just bench-jolt-sha3 "{{sha3_args}}"
    just bench-jolt-sha3-chain "{{sha3_chain_args}}"
    just bench-jolt-mat-mul "{{matmul_args}}"
    just bench-jolt-ec "{{ec_args}}"

bench-jolt-fib fib_args:
    -for arg in {{fib_args}}; do ./scripts/bench.sh "jolt" "fib" "$arg"; done

bench-jolt-sha2 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "jolt" "sha2" "$arg"; done

bench-jolt-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "jolt" "sha2-chain" "$arg"; done

bench-jolt-sha3 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "jolt" "sha3" "$arg"; done

bench-jolt-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "jolt" "sha3-chain" "$arg"; done

bench-jolt-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./scripts/bench.sh "jolt" "mat-mul" "$arg"; done

bench-jolt-ec ec_args:
    -for arg in {{ec_args}}; do ./scripts/bench.sh "jolt" "ec" "$arg"; done


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
	cd sp1 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-sp1 fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: check-setup build-sp1
    just bench-sp1-fib "{{fib_args}}"
    just bench-sp1-sha2 "{{sha2_args}}"
    just bench-sp1-sha2-chain "{{sha2_chain_args}}"
    just bench-sp1-sha3 "{{sha3_args}}"
    just bench-sp1-sha3-chain "{{sha3_chain_args}}"
    just bench-sp1-mat-mul "{{matmul_args}}"
    just bench-sp1-sha2-precompile "{{sha2_args}}"
    just bench-sp1-sha2-chain-precompile "{{sha2_chain_args}}"
    just bench-sp1-sha3-precompile "{{sha3_args}}"
    just bench-sp1-sha3-chain-precompile "{{sha3_chain_args}}"
    just bench-sp1-ec "{{ec_args}}"
    # just bench-sp1-ec-precompile "{{ec_args}}"

bench-sp1-fib fib_args:
    -for arg in {{fib_args}}; do ./scripts/bench.sh "sp1" "fib" "$arg"; done

bench-sp1-sha2 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "sp1" "sha2" "$arg"; done

bench-sp1-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "sp1" "sha2-chain" "$arg"; done

bench-sp1-sha2-precompile sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "sp1" "sha2-precompile" "$arg"; done

bench-sp1-sha2-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "sp1" "sha2-chain-precompile" "$arg"; done

bench-sp1-sha3-precompile sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "sp1" "sha3-precompile" "$arg"; done

bench-sp1-sha3-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "sp1" "sha3-chain-precompile" "$arg"; done

bench-sp1-sha3 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "sp1" "sha3" "$arg"; done

bench-sp1-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "sp1" "sha3-chain" "$arg"; done

bench-sp1-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./scripts/bench.sh "sp1" "mat-mul" "$arg"; done

bench-sp1-ec ec_args:
    -for arg in {{ec_args}}; do ./scripts/bench.sh "sp1" "ec" "$arg"; done

bench-sp1-ec-precompile ec_args:
    -for arg in {{ec_args}}; do ./scripts/bench.sh "sp1" "ec-precompile" "$arg"; done


#####
# risczero
#####

build-risczero:
    cd risczero/fib && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha2 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha2-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha3 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha3-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha2-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha2-chain-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha3-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha3-chain-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/ec && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/ec-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release    
    cd risczero/mat-mul && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-risczero fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: check-setup build-risczero
    just bench-risczero-fib "{{fib_args}}"
    just bench-risczero-sha2 "{{sha2_args}}"
    just bench-risczero-sha2-chain "{{sha2_chain_args}}"
    just bench-risczero-sha2-precompile "{{sha2_args}}"
    just bench-risczero-sha2-chain-precompile "{{sha2_chain_args}}"
    just bench-risczero-sha3 "{{sha3_args}}"
    just bench-risczero-sha3-precompile "{{sha3_args}}"
    just bench-risczero-sha3-chain "{{sha3_chain_args}}"
    just bench-risczero-sha3-chain-precompile "{{sha3_chain_args}}"
    just bench-risczero-mat-mul "{{matmul_args}}"
    just bench-risczero-ec "{{ec_args}}"
    just bench-risczero-ec-precompile "{{ec_args}}"

bench-risczero-fib fib_args:
    -for arg in {{fib_args}}; do ./scripts/bench.sh "risczero" "fib" "$arg"; done

bench-risczero-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./scripts/bench.sh "risczero" "mat-mul" "$arg"; done

bench-risczero-sha2 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "risczero" "sha2" "$arg"; done

bench-risczero-sha2-precompile sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "risczero" "sha2-precompile" "$arg"; done

bench-risczero-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "risczero" "sha2-chain" "$arg"; done

bench-risczero-sha2-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "risczero" "sha2-chain-precompile" "$arg"; done

bench-risczero-sha3 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "risczero" "sha3" "$arg"; done

bench-risczero-sha3-precompile sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "risczero" "sha3-precompile" "$arg"; done

bench-risczero-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "risczero" "sha3-chain" "$arg"; done

bench-risczero-sha3-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "risczero" "sha3-chain-precompile" "$arg"; done

bench-risczero-ec ec_args:
    -for arg in {{ec_args}}; do ./scripts/bench.sh "risczero" "ec" "$arg"; done

bench-risczero-ec-precompile ec_args:
    -for arg in {{ec_args}}; do ./scripts/bench.sh "risczero" "ec-precompile" "$arg"; done

#####
# Stone
#####

build-stone:
    cd stone/common && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/fib && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha3 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha3-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha3-builtin && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha3-chain-builtin && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha2 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha2-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/mat-mul && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/ec && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-stone fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: check-setup build-stone
    just bench-stone-fib "{{fib_args}}"
    just bench-stone-sha3 "{{sha3_args}}"
    just bench-stone-sha3-chain "{{sha3_chain_args}}"
    just bench-stone-sha3-builtin "{{sha3_args}}"
    just bench-stone-sha3-chain-builtin "{{sha3_chain_args}}"
    just bench-stone-mat "{{matmul_args}}"
    just bench-stone-sha2 "{{sha2_args}}"
    just bench-stone-sha2-chain "{{sha2_chain_args}}"
    just bench-stone-ec "{{ec_args}}"

bench-stone-fib fib_args:
    -for arg in {{fib_args}}; do ./scripts/bench.sh "stone" "fib" "$arg"; done

bench-stone-mat matmul_args:
    -for arg in {{matmul_args}}; do ./scripts/bench.sh "stone" "mat-mul" "$arg"; done

bench-stone-sha3 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "stone" "sha3" "$arg"; done

bench-stone-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "stone" "sha3-chain" "$arg"; done

bench-stone-sha3-builtin sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "stone" "sha3-builtin" "$arg"; done

bench-stone-sha3-chain-builtin sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "stone" "sha3-chain-builtin" "$arg"; done

bench-stone-sha2 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "stone" "sha2" "$arg"; done

bench-stone-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "stone" "sha2-chain" "$arg"; done

bench-stone-ec ec_args:
    -for arg in {{ec_args}}; do ./scripts/bench.sh "stone" "ec" "$arg"; done


#####
# Stwo
#####

build-stwo:
    cd stwo && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-stwo fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: check-setup build-stwo
    just bench-stwo-fib "{{fib_args}}"
    just bench-stwo-sha2 "{{sha2_args}}"
    just bench-stwo-sha2-chain "{{sha2_chain_args}}"
    just bench-stwo-sha3 "{{sha3_args}}"
    just bench-stwo-sha3-chain "{{sha3_chain_args}}"
    just bench-stwo-mat-mul "{{matmul_args}}"
    just bench-stwo-ec "{{ec_args}}"

bench-stwo-fib fib_args:
    -for arg in {{fib_args}}; do ./scripts/bench.sh "stwo" "fib" "$arg"; done

bench-stwo-sha2 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "stwo" "sha2" "$arg"; done

bench-stwo-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "stwo" "sha2-chain" "$arg"; done

bench-stwo-sha3 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "stwo" "sha3" "$arg"; done

bench-stwo-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "stwo" "sha3-chain" "$arg"; done

bench-stwo-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./scripts/bench.sh "stwo" "mat-mul" "$arg"; done

bench-stwo-ec ec_args:
    -for arg in {{ec_args}}; do ./scripts/bench.sh "stwo" "ec" "$arg"; done


#####
# openvm
#####

build-openvm:
    cd openvm && rustup install
    cd openvm && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-openvm fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: check-setup build-openvm
    just bench-openvm-fib "{{fib_args}}"
    just bench-openvm-sha2 "{{sha2_args}}"
    just bench-openvm-sha2-chain "{{sha2_chain_args}}"
    just bench-openvm-sha3 "{{sha3_args}}"
    just bench-openvm-sha3-chain "{{sha3_chain_args}}"
    just bench-openvm-sha2-precompile "{{sha2_args}}"
    just bench-openvm-sha2-chain-precompile "{{sha2_chain_args}}"
    just bench-openvm-sha3-precompile "{{sha3_args}}"
    just bench-openvm-sha3-chain-precompile "{{sha3_chain_args}}"
    just bench-openvm-mat-mul "{{matmul_args}}"
    just bench-openvm-ec "{{ec_args}}"
    just bench-openvm-ec-precompile "{{ec_args}}"

bench-openvm-fib fib_args:
    -for arg in {{fib_args}}; do ./scripts/bench.sh "openvm" "fib" "$arg"; done

bench-openvm-sha2 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "openvm" "sha2" "$arg"; done

bench-openvm-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "openvm" "sha2-chain" "$arg"; done

bench-openvm-sha3 sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "openvm" "sha3" "$arg"; done

bench-openvm-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "openvm" "sha3-chain" "$arg"; done

bench-openvm-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./scripts/bench.sh "openvm" "mat-mul" "$arg"; done

bench-openvm-sha2-precompile sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "openvm" "sha2-precompile" "$arg"; done

bench-openvm-sha2-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "openvm" "sha2-chain-precompile" "$arg"; done

bench-openvm-sha3-precompile sha_args:
    -for arg in {{sha_args}}; do ./scripts/bench.sh "openvm" "sha3-precompile" "$arg"; done

bench-openvm-sha3-chain-precompile sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./scripts/bench.sh "openvm" "sha3-chain-precompile" "$arg"; done

bench-openvm-ec ec_args:
    -for arg in {{ec_args}}; do ./scripts/bench.sh "openvm" "ec" "$arg"; done

bench-openvm-ec-precompile ec_args:
    -for arg in {{ec_args}}; do ./scripts/bench.sh "openvm" "ec-precompile" "$arg"; done