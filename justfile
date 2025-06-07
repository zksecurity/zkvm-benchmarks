# Default recipe
default:
    just bench-all

# Build utilities
build-utils:
    cd utils && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

# Bench all
bench-all fib_args sha_args sha_chain_args matmul_args ec_args: build-utils
    # just bench-stone "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}" "{{ec_args}}"
    # just bench-stwo "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}" "{{ec_args}}"
    # just bench-jolt "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}" "{{ec_args}}"
    # just bench-sp1 "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}" "{{ec_args}}"
    just bench-risczero "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}" "{{ec_args}}"
    just bench-openvm "{{fib_args}}" "{{sha_args}}" "{{sha_chain_args}}" "{{matmul_args}}" "{{ec_args}}"


#####
# jolt
#####

build-jolt:
    cd jolt && rustup install
    cd jolt && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

# bench-all takes arguments for all benchmarks
bench-jolt fib_args sha_args sha_chain_args matmul_args ec_args: build-jolt
    just bench-jolt-fib "{{fib_args}}"
    just bench-jolt-sha2 "{{sha_args}}"
    just bench-jolt-sha2-chain "{{sha_chain_args}}"
    just bench-jolt-sha3 "{{sha_args}}"
    just bench-jolt-sha3-chain "{{sha_chain_args}}"
    just bench-jolt-mat-mul "{{matmul_args}}"
    # just bench-jolt-ec "{{ec_args}}"

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

bench-jolt-mat-mul matmul_args:
    -for arg in {{matmul_args}}; do ./bench_zkvm.sh "jolt" "mat-mul" "$arg"; done

bench-jolt-ec ec_args:
    -for arg in {{ec_args}}; do ./bench_zkvm.sh "jolt" "ec" "$arg"; done


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

bench-sp1 fib_args sha_args sha_chain_args matmul_args ec_args: build-sp1
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
    # just bench-sp1-ec "{{ec_args}}"
    # just bench-sp1-ec-precompile "{{ec_args}}"

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

bench-sp1-ec ec_args:
    -for arg in {{ec_args}}; do ./bench_zkvm.sh "sp1" "ec" "$arg"; done

bench-sp1-ec-precompile ec_args:
    -for arg in {{ec_args}}; do ./bench_zkvm.sh "sp1" "ec-precompile" "$arg"; done


#####
# risczero
#####

build-risczero:
    # cd risczero/fib && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    # cd risczero/sha2 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    # cd risczero/sha2-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    # cd risczero/sha3 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    # cd risczero/sha3-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    # cd risczero/sha2-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    # cd risczero/sha2-chain-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha3-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    # cd risczero/sha3-chain-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    # cd risczero/ec && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    # cd risczero/ec-precompile && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release    
    # cd risczero/mat-mul && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-risczero fib_args sha_args sha_chain_args matmul_args ec_args: build-risczero
    # just bench-risczero-fib "{{fib_args}}"
    # just bench-risczero-sha2 "{{sha_args}}"
    # just bench-risczero-sha2-chain "{{sha_chain_args}}"
    # just bench-risczero-sha2-precompile "{{sha_args}}"
    # just bench-risczero-sha2-chain-precompile "{{sha_chain_args}}"
    # just bench-risczero-sha3 "{{sha_args}}"
    # just bench-risczero-sha3-precompile "{{sha_args}}"
    just bench-risczero-sha3-chain "{{sha_chain_args}}"
    # just bench-risczero-sha3-chain-precompile "{{sha_chain_args}}"
    # just bench-risczero-mat-mul "{{matmul_args}}"
    # just bench-risczero-ec "{{ec_args}}"
    # just bench-risczero-ec-precompile "{{ec_args}}"

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

bench-risczero-ec ec_args:
    -for arg in {{ec_args}}; do ./bench_zkvm.sh "risczero" "ec" "$arg"; done

bench-risczero-ec-precompile ec_args:
    -for arg in {{ec_args}}; do ./bench_zkvm.sh "risczero" "ec-precompile" "$arg"; done

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
    -just build-stone-steps

build-stone-steps:
	-cd stone && git clone https://github.com/lambdaclass/cairo-vm.git
	-cd stone/cairo-vm/cairo1-run && make deps

bench-stone fib_args sha_args sha_chain_args matmul_args ec_args: build-stone
    just bench-stone-fib "{{fib_args}}"
    just bench-stone-sha3 "{{sha_args}}"
    just bench-stone-sha3-chain "{{sha_chain_args}}"
    just bench-stone-sha3-builtin "{{sha_args}}"
    just bench-stone-sha3-chain-builtin "{{sha_chain_args}}"
    just bench-stone-mat "{{matmul_args}}"
    just bench-stone-sha2 "{{sha_args}}"
    just bench-stone-sha2-chain "{{sha_chain_args}}"
    # just bench-stone-ec "{{ec_args}}"

bench-stone-fib fib_args:
    -for arg in {{fib_args}}; do ./bench_zkvm.sh "stone" "fib" "$arg"; done

bench-stone-mat matmul_args:
    -for arg in {{matmul_args}}; do ./bench_zkvm.sh "stone" "mat-mul" "$arg"; done

bench-stone-sha3 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "stone" "sha3" "$arg"; done

bench-stone-sha3-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "stone" "sha3-chain" "$arg"; done

bench-stone-sha3-builtin sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "stone" "sha3-builtin" "$arg"; done

bench-stone-sha3-chain-builtin sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "stone" "sha3-chain-builtin" "$arg"; done

bench-stone-sha2 sha_args:
    -for arg in {{sha_args}}; do ./bench_zkvm.sh "stone" "sha2" "$arg"; done

bench-stone-sha2-chain sha_chain_args:
    -for arg in {{sha_chain_args}}; do ./bench_zkvm.sh "stone" "sha2-chain" "$arg"; done

bench-stone-ec ec_args:
    -for arg in {{ec_args}}; do ./bench_zkvm.sh "stone" "ec" "$arg"; done


#####
# Stwo
#####

build-stwo:
    cd stwo && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-stwo fib_args sha_args sha_chain_args matmul_args ec_args: build-stwo
    just bench-stwo-fib "{{fib_args}}"
    just bench-stwo-sha2 "{{sha_args}}"
    just bench-stwo-sha2-chain "{{sha_chain_args}}"
    just bench-stwo-sha3 "{{sha_args}}"
    just bench-stwo-sha3-chain "{{sha_chain_args}}"
    just bench-stwo-mat-mul "{{matmul_args}}"
    # just bench-stwo-ec "{{ec_args}}"

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

bench-stwo-ec ec_args:
    -for arg in {{ec_args}}; do ./bench_zkvm.sh "stwo" "ec" "$arg"; done


#####
# openvm
#####

build-openvm:
    cd openvm && rustup install
    cd openvm && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-openvm fib_args sha_args sha_chain_args matmul_args ec_args: build-openvm
    # just bench-openvm-fib "{{fib_args}}"
    # just bench-openvm-sha2 "{{sha_args}}"
    # just bench-openvm-sha2-chain "{{sha_chain_args}}"
    # just bench-openvm-sha3 "{{sha_args}}"
    just bench-openvm-sha3-chain "{{sha_chain_args}}"
    # just bench-openvm-sha2-precompile "{{sha_args}}"
    # just bench-openvm-sha2-chain-precompile "{{sha_chain_args}}"
    # just bench-openvm-sha3-precompile "{{sha_args}}"
    # just bench-openvm-sha3-chain-precompile "{{sha_chain_args}}"
    # just bench-openvm-mat-mul "{{matmul_args}}"
    # just bench-openvm-ec "{{ec_args}}"
    # just bench-openvm-ec-precompile "{{ec_args}}"

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

bench-openvm-ec ec_args:
    -for arg in {{ec_args}}; do ./bench_zkvm.sh "openvm" "ec" "$arg"; done