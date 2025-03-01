# Define variables
FIB_ARGS := "5000 10000 50000 100000 500000 1000000"
EC_ARGS := "8 16 32 64 128"
SHA_ARGS := "256 512 1024 2048 4096"
BINARY_SEARCH_ARGS := "128 256 512 1024 2048"
SHA_CHAIN_ARGS := "230 460 920 1840 3680"
MATMUL_ARGS := "10 20 40 60"

# Default recipe
default:
    just bench-all

# Build utilities
build-utils:
    cd utils && cargo build --release

# Bench all
bench-all: build-utils
    # just bench-jolt
    # just bench-risczero
    just bench-stone
    # just bench-sp1
    # just bench-stwo


#####
# jolt
#####

bench-jolt:
    cd jolt && cargo build --release
    just bench-jolt-fib
    just bench-jolt-sha2
    just bench-jolt-sha2-chain
    just bench-jolt-sha3
    just bench-jolt-sha3-chain
    just bench-jolt-mat-mul
    just bench-jolt-ec
    # just bench-jolt-binary-search

bench-jolt-fib:
	just bench-jolt-fib-time
	# just bench-jolt-fib-mem

bench-jolt-fib-time:
    -for arg in {{FIB_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program fib && cd ..; done

bench-jolt-fib-mem:
    -for arg in {{FIB_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg "$arg" --bench-mem -- --program fib && cd ..; done


bench-jolt-ec:
	just bench-jolt-ec-time
	# just bench-jolt-ec-mem

bench-jolt-ec-time:
    -for arg in {{EC_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-ec --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program ec && cd ..; done

bench-jolt-ec-mem:
    -for arg in {{EC_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-ec --bin target/release/jolt-benchmarks --bench-arg "$arg" --bench-mem -- --program ec && cd ..; done


bench-jolt-sha2:
	just bench-jolt-sha2-time
	# just bench-jolt-sha2-mem

bench-jolt-sha2-time:
    -for arg in {{SHA_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program sha2 && cd ..; done

bench-jolt-sha2-mem:
    -for arg in {{SHA_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg "$arg" --bench-mem -- --program sha2 && cd ..; done


bench-jolt-sha2-chain:
	just bench-jolt-sha2-chain-time
	# just bench-jolt-sha2-chain-mem

bench-jolt-sha2-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program sha2-chain && cd ..; done

bench-jolt-sha2-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg "$arg" --bench-mem -- --program sha2-chain && cd ..; done


bench-jolt-sha3:
	just bench-jolt-sha3-time
	# just bench-jolt-sha3-mem

bench-jolt-sha3-time:
    -for arg in {{SHA_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program sha3 && cd ..; done

bench-jolt-sha3-mem:
    -for arg in {{SHA_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg "$arg" --bench-mem -- --program sha3 && cd ..; done


bench-jolt-sha3-chain:
	just bench-jolt-sha3-chain-time
	# just bench-jolt-sha3-chain-mem

bench-jolt-sha3-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program sha3-chain && cd ..; done

bench-jolt-sha3-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg "$arg" --bench-mem -- --program sha3-chain && cd ..; done


bench-jolt-mat-mul:
	just bench-jolt-mat-mul-time
	# just bench-jolt-mat-mul-mem

bench-jolt-mat-mul-time:
	-for arg in {{MATMUL_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program mat-mul && cd ..; done

bench-jolt-mat-mul-mem:
	-for arg in {{MATMUL_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg "$arg" --bench-mem -- --program mat-mul && cd ..; done


# bench-jolt-binary-search:
# 	just bench-jolt-binary-search-time
# 	just bench-jolt-binary-search-mem

# bench-jolt-binary-search-time:
# 	-for arg in {{BINARY_SEARCH_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program binary-search && cd ..; done

# bench-jolt-binary-search-mem:
# 	-for arg in {{BINARY_SEARCH_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg "$arg" --bench-mem -- --program binary-search && cd ..; done



#####
# sp1
#####

build-sp1:
	cd sp1/fib && cargo prove build
	cd sp1/sha2-chain && cargo prove build
	cd sp1/sha3-chain && cargo prove build
	cd sp1/sha2 && cargo prove build
	cd sp1/sha3 && cargo prove build
	cd sp1/bigmem && cargo prove build
	cd sp1/binary-search && cargo prove build
	cd sp1/mat-mul && cargo prove build
	cd sp1/sha2-precompile && cargo prove build
	cd sp1/sha2-chain-precompile && cargo prove build
	cd sp1/sha3-precompile && cargo prove build
	cd sp1/sha3-chain-precompile && cargo prove build
	cd sp1/ec && cargo prove build
	cd sp1/ec-precompile && cargo prove build
	cd sp1 && cargo build --release

bench-sp1: build-sp1
    just bench-sp1-time
    # just bench-sp1-mem

bench-sp1-time:
	just bench-sp1-fib-time
	just bench-sp1-sha2-time
	just bench-sp1-sha2-chain-time
	just bench-sp1-sha3-time
	just bench-sp1-sha3-chain-time
	just bench-sp1-mat-mul-time
	# just bench-sp1-binary-search-time
	just bench-sp1-sha2-precompile-time
	just bench-sp1-sha3-precompile-time
	just bench-sp1-sha2-chain-precompile-time
	just bench-sp1-sha3-chain-precompile-time
	just bench-sp1-ec-time
	just bench-sp1-ec-precompile-time

bench-sp1-mem:
    just bench-sp1-fib-mem
    just bench-sp1-sha2-mem
    just bench-sp1-sha2-chain-mem
    just bench-sp1-sha3-mem
    just bench-sp1-sha3-chain-mem
    just bench-sp1-mat-mul-mem
    just bench-sp1-binary-search-mem
    just bench-sp1-sha2-precompile-mem
    just bench-sp1-sha3-precompile-mem
    just bench-sp1-sha2-chain-precompile-mem
    just bench-sp1-sha3-chain-precompile-mem
    just bench-sp1-ec-mem
    just bench-sp1-ec-precompile-mem

bench-sp1-fib-time:
    -for arg in {{FIB_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg "$arg" -- --program fib && cd ..; done

bench-sp1-fib-mem:
    -for arg in {{FIB_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program fib && cd ..; done

# bench-sp1-fib-script:
#     -for arg in {{FIB_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "sp1" "fib" "$arg"; done

bench-sp1-ec-time:
    -for arg in {{EC_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-ec --bin target/release/sp1-script --bench-arg "$arg" -- --program ec && cd ..; done

bench-sp1-ec-mem:
    -for arg in {{EC_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-ec --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program ec && cd ..; done

bench-sp1-ec-precompile-time:
    -for arg in {{EC_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-ec-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program ec-precompile && cd ..; done

bench-sp1-ec-precompile-mem:
    -for arg in {{EC_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-ec-precompile --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program ec-precompile && cd ..; done

bench-sp1-sha2-time:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg "$arg" -- --program sha2 && cd ..; done

bench-sp1-sha2-mem:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program sha2 && cd ..; done

bench-sp1-sha2-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg "$arg" -- --program sha2-chain && cd ..; done

bench-sp1-sha2-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program sha2-chain && cd ..; done

bench-sp1-sha2-precompile-time:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program sha2-precompile && cd ..; done

bench-sp1-sha2-precompile-mem:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program sha2-precompile && cd ..; done

bench-sp1-sha2-chain-precompile-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program sha2-chain-precompile && cd ..; done

bench-sp1-sha2-chain-precompile-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program sha2-chain-precompile && cd ..; done

bench-sp1-sha3-precompile-time:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program sha3-precompile && cd ..; done

bench-sp1-sha3-precompile-mem:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program sha3-precompile && cd ..; done

bench-sp1-sha3-chain-precompile-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program sha3-chain-precompile && cd ..; done

bench-sp1-sha3-chain-precompile-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program sha3-chain-precompile && cd ..; done

bench-sp1-sha3-time:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg "$arg" -- --program sha3 && cd ..; done

bench-sp1-sha3-mem:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program sha3 && cd ..; done

bench-sp1-sha3-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg "$arg" -- --program sha3-chain && cd ..; done

bench-sp1-sha3-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program sha3-chain && cd ..; done

bench-sp1-mat-mul-time:
    -for arg in {{MATMUL_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg "$arg" -- --program mat-mul && cd ..; done

bench-sp1-mat-mul-mem:
    -for arg in {{MATMUL_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program mat-mul && cd ..; done

# bench-sp1-binary-search-time:
#     -for arg in {{BINARY_SEARCH_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg "$arg" -- --program binary-search && cd ..; done

# bench-sp1-binary-search-mem:
#     -for arg in {{BINARY_SEARCH_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg "$arg" --bench-mem -- --program binary-search && cd ..; done


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
    # cd risczero/binary-search && cargo build --release

bench-risczero: build-risczero
    just bench-risczero-fib
    just bench-risczero-sha2  
    just bench-risczero-sha2-precompile
    just bench-risczero-sha3
    just bench-risczero-sha3-precompile
    just bench-risczero-sha2-chain
    just bench-risczero-sha2-chain-precompile
    just bench-risczero-sha3-chain
    just bench-risczero-sha3-chain-precompile
    just bench-risczero-ec  
    just bench-risczero-ec-precompile  
    just bench-risczero-mat-mul
    # just bench-risczero-binary-search

bench-risczero-fib:
    -for arg in {{FIB_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "fib" "$arg"; done

bench-risczero-ec:
    -for arg in {{EC_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "ec" "$arg"; done

bench-risczero-ec-precompile:
    -for arg in {{EC_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "ec-precompile" "$arg"; done

# bench-risczero-binary-search:
#     -for arg in {{BINARY_SEARCH_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "binary-search" "$arg"; done

bench-risczero-mat-mul:
    -for arg in {{MATMUL_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "mat-mul" "$arg"; done

bench-risczero-sha2:
    -for arg in {{SHA_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "sha2" "$arg"; done

bench-risczero-sha2-precompile:
    -for arg in {{SHA_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "sha2-precompile" "$arg"; done

bench-risczero-sha2-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "sha2-chain" "$arg"; done

bench-risczero-sha2-chain-precompile:
    -for arg in {{SHA_CHAIN_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "sha2-chain-precompile" "$arg"; done

bench-risczero-sha3:
    -for arg in {{SHA_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "sha3" "$arg"; done

bench-risczero-sha3-precompile:
    -for arg in {{SHA_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "sha3-precompile" "$arg"; done

bench-risczero-sha3-chain:
    -for arg in {{SHA_CHAIN_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "sha3-chain" "$arg"; done

bench-risczero-sha3-chain-precompile:
    -for arg in {{SHA_CHAIN_ARGS}}; do sudo PATH="$PATH" ./bench_zkvm.sh "risczero" "sha3-chain-precompile" "$arg"; done

#####
# Stone
#####

bench-stone: build-stone
    just bench-stone-time
    # just bench-stone-mem

bench-stone-time:
    just bench-stone-fib-time
    just bench-stone-keccak-time
    just bench-stone-keccak-builtin-time
    just bench-stone-keccak-builtin-chain-time
    just bench-stone-mat-time
    # just bench-stone-binary-search-time
    just bench-stone-sha256-time
    just bench-stone-sha256-chain-time

bench-stone-mem:
    just bench-stone-fib-mem
    just bench-stone-keccak-mem
    just bench-stone-keccak-builtin-mem
    just bench-stone-keccak-builtin-chain-mem
    just bench-stone-mat-mem
    just bench-stone-binary-search-mem
    just bench-stone-sha256-mem
    just bench-stone-sha256-chain-mem

build-stone:
    cd stone/common && cargo build --release
    # cd stone/binary-search && cargo build --release
    cd stone/fibonacci && cargo build --release
    cd stone/keccak && cargo build --release
    cd stone/keccak-builtin && cargo build --release
    cd stone/keccak-builtin-chain && cargo build --release
    cd stone/sha256 && cargo build --release
    cd stone/sha256-chain && cargo build --release
    cd stone/mat-mul && cargo build --release
    -just build-stone-steps

build-stone-steps:
	-cd stone && git clone https://github.com/lambdaclass/cairo-vm.git
	-cd stone/cairo-vm/cairo1-run && make deps

bench-stone-fib-time:
    -for arg in {{FIB_ARGS}}; do cd stone/fibonacci && ../../utils/target/release/utils --bench-name stone-fib --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-fib-mem:
    -for arg in {{FIB_ARGS}}; do cd stone/fibonacci && ../../utils/target/release/utils --bench-name stone-fib --bin target/release/stone --bench-arg "$arg" --bench-mem && cd ../..; done

bench-stone-mat-time:
    -for arg in {{MATMUL_ARGS}}; do cd stone/mat-mul && ../../utils/target/release/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-mat-mem:
    -for arg in {{MATMUL_ARGS}}; do cd stone/mat-mul && ../../utils/target/release/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg "$arg" --bench-mem && cd ../..; done

bench-stone-binary-search-time:
    -for arg in {{BINARY_SEARCH_ARGS}}; do cd stone/binary-search && ../../utils/target/release/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-binary-search-mem:
    -for arg in {{BINARY_SEARCH_ARGS}}; do cd stone/binary-search && ../../utils/target/release/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg "$arg" --bench-mem && cd ../..; done

bench-stone-keccak-time:
    -for arg in {{SHA_ARGS}}; do cd stone/keccak && ../../utils/target/release/utils --bench-name stone-sha3 --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-keccak-mem:
    -for arg in {{SHA_ARGS}}; do cd stone/keccak && ../../utils/target/release/utils --bench-name stone-sha3 --bin target/release/stone --bench-arg "$arg" --bench-mem && cd ../..; done

# representing bytes 200, 400, 1000, 2000
# as each iteration of the keccak builtin processes 200 bytes
# let inputs = [1, 2, 5, 10];
bench-stone-keccak-builtin-time:
    -for arg in 1 2 5 10; do cd stone/keccak-builtin && ../../utils/target/release/utils --bench-name stone-sha3-builtin --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-keccak-builtin-mem:
    -for arg in 1 2 5 10; do cd stone/keccak-builtin && ../../utils/target/release/utils --bench-name stone-sha3-builtin --bin target/release/stone --bench-arg "$arg" --bench-mem && cd ../..; done

# other programs use:
# 32 bytes * 230 = 7360 bytes
# 32 bytes * 460 = 14720 bytes
# 32 bytes * 920 = 29440 bytes
# 32 bytes * 1840 = 58880 bytes
# 32 bytes * 3680 = 117760 bytes
# to adapt to the 200 bytes per iteration of the keccak builtin,
# the number of equivalent iterations is:
# 7360 / 200 = 36.8
# 14720 / 200 = 73.6
# 29440 / 200 = 147.2
# 58880 / 200 = 294.4
# 117760 / 200 = 588.8
bench-stone-keccak-builtin-chain-time:
    -for arg in 37 74 148 295 589; do cd stone/keccak-builtin && ../../utils/target/release/utils --bench-name stone-sha3-chain-builtin --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-keccak-builtin-chain-mem:
    -for arg in 37 74 148 295 589; do cd stone/keccak-builtin && ../../utils/target/release/utils --bench-name stone-sha3-chain-builtin --bin target/release/stone --bench-arg "$arg" --bench-mem && cd ../..; done

bench-stone-sha256-time:
    -for arg in {{SHA_ARGS}}; do cd stone/sha256 && ../../utils/target/release/utils --bench-name stone-sha2 --bin target/release/sha256 --bench-arg "$arg" && cd ../..; done

bench-stone-sha256-mem:
    -for arg in {{SHA_ARGS}}; do cd stone/sha256 && ../../utils/target/release/utils --bench-name stone-sha2 --bin target/release/sha256 --bench-arg "$arg" --bench-mem && cd ../..; done

bench-stone-sha256-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd stone/sha256-chain && ../../utils/target/release/utils --bench-name stone-sha2-chain --bin target/release/sha256-chain --bench-arg "$arg" && cd ../..; done

bench-stone-sha256-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd stone/sha256-chain && ../../utils/target/release/utils --bench-name stone-sha2-chain --bin target/release/sha256-chain --bench-arg "$arg" --bench-mem && cd ../..; done


#####
# Stwo
#####

bench-stwo: build-stwo
	just bench-stwo-time

build-stwo:
    cd stwo && cargo build --release
    cd stwo/fibonacci && scarb build
    -cd stwo && git clone https://github.com/starkware-libs/stwo-cairo.git
    cd stwo/stwo-cairo/stwo_cairo_prover && cargo build --release
    cd stwo/stwo-cairo/stwo_cairo_verifier && cargo build --release

bench-stwo-time:
	just bench-stwo-fibonacci-time
	just bench-stwo-sha2-time
	just bench-stwo-sha3-time

bench-stwo-fibonacci-time:
    -for arg in {{FIB_ARGS}}; do cd stwo && ../utils/target/release/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg "$arg" -- --program fib && cd ..; done

bench-stwo-sha2-time:
    -for arg in {{SHA_ARGS}}; do cd stwo && ../utils/target/release/utils --bench-name stwo-sha2 --bin target/release/stwo-script --bench-arg "$arg" -- --program sha2 && cd ..; done

bench-stwo-sha3-time:
    -for arg in {{SHA_ARGS}}; do cd stwo && ../utils/target/release/utils --bench-name stwo-sha3 --bin target/release/stwo-script --bench-arg "$arg" -- --program sha3 && cd ..; done
