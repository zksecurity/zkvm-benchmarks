# Define variables
FIB_ARGS := "5000 10000 50000 100000 500000 1000000"
EC_ARGS := "8 16 32 64 128"
SHA_ARGS := "256 512 1024 2048 4096"
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
    just bench-jolt-mem
    just bench-jolt-time

bench-jolt-mem:
    just bench-jolt-fib-mem
    just bench-jolt-sha2-mem
    # just bench-jolt-sha2-chain-mem
    just bench-jolt-sha3-mem
    just bench-jolt-sha3-chain-mem
    # just bench-jolt-mat-mul-mem
    # just bench-jolt-ec-mem

bench-jolt-time:
    just bench-jolt-fib-time
    just bench-jolt-sha2-time
    # just bench-jolt-sha2-chain-time
    just bench-jolt-sha3-time
    just bench-jolt-sha3-chain-time
    # just bench-jolt-mat-mul-time
    # just bench-jolt-ec-time


bench-jolt-fib-time:
    -for arg in {{FIB_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program fib && cd ..; done

bench-jolt-fib-mem:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "jolt" "fib" "$arg"; done


bench-jolt-ec-time:
    -for arg in {{EC_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-ec --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program ec && cd ..; done

bench-jolt-ec-mem:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "jolt" "ec" "$arg"; done


bench-jolt-sha2-time:
    -for arg in {{SHA_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program sha2 && cd ..; done

bench-jolt-sha2-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "jolt" "sha2" "$arg"; done


bench-jolt-sha2-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program sha2-chain && cd ..; done

bench-jolt-sha2-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "jolt" "sha2-chain" "$arg"; done


bench-jolt-sha3-time:
    -for arg in {{SHA_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program sha3 && cd ..; done

bench-jolt-sha3-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "jolt" "sha3" "$arg"; done


bench-jolt-sha3-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program sha3-chain && cd ..; done

bench-jolt-sha3-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "jolt" "sha3-chain" "$arg"; done


bench-jolt-mat-mul-time:
	-for arg in {{MATMUL_ARGS}}; do cd jolt && ../utils/target/release/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg "$arg" -- --program mat-mul && cd ..; done

bench-jolt-mat-mul-mem:
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
	cd sp1/bigmem && cargo prove build
	cd sp1/mat-mul && cargo prove build
	cd sp1/sha2-precompile && cargo prove build
	cd sp1/sha2-chain-precompile && cargo prove build
	cd sp1/sha3-precompile && cargo prove build
	cd sp1/sha3-chain-precompile && cargo prove build
	cd sp1/ec && cargo prove build
	cd sp1/ec-precompile && cargo prove build
	cd sp1 && cargo build --release

bench-sp1: build-sp1
    just bench-sp1-mem
    just bench-sp1-time

bench-sp1-mem:
    just bench-sp1-fib-mem
    just bench-sp1-sha2-mem
    # just bench-sp1-sha2-chain-mem
    just bench-sp1-sha3-mem
    just bench-sp1-sha3-chain-mem
    just bench-sp1-mat-mul-mem
    just bench-sp1-sha2-precompile-mem
    just bench-sp1-sha3-precompile-mem
    # just bench-sp1-sha2-chain-precompile-mem
    just bench-sp1-sha3-chain-precompile-mem
    # just bench-sp1-ec-mem
    # just bench-sp1-ec-precompile-mem

bench-sp1-time:
	just bench-sp1-fib-time
	just bench-sp1-sha2-time
	# just bench-sp1-sha2-chain-time
	just bench-sp1-sha3-time
	just bench-sp1-sha3-chain-time
	just bench-sp1-mat-mul-time
	just bench-sp1-sha2-precompile-time
	just bench-sp1-sha3-precompile-time
	# just bench-sp1-sha2-chain-precompile-time
	just bench-sp1-sha3-chain-precompile-time
	# just bench-sp1-ec-time
	# just bench-sp1-ec-precompile-time


bench-sp1-fib-time:
    -for arg in {{FIB_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg "$arg" -- --program fib && cd ..; done

bench-sp1-fib-mem:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "sp1" "fib" "$arg"; done

bench-sp1-ec-time:
    -for arg in {{EC_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-ec --bin target/release/sp1-script --bench-arg "$arg" -- --program ec && cd ..; done

bench-sp1-ec-mem:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "sp1" "ec" "$arg"; done

bench-sp1-ec-precompile-time:
    -for arg in {{EC_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-ec-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program ec-precompile && cd ..; done

bench-sp1-ec-precompile-mem:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "sp1" "ec-precompile" "$arg"; done

bench-sp1-sha2-time:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg "$arg" -- --program sha2 && cd ..; done

bench-sp1-sha2-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "sp1" "sha2" "$arg"; done

bench-sp1-sha2-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg "$arg" -- --program sha2-chain && cd ..; done

bench-sp1-sha2-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "sp1" "sha2-chain" "$arg"; done

bench-sp1-sha2-precompile-time:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program sha2-precompile && cd ..; done

bench-sp1-sha2-precompile-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "sp1" "sha2-precompile" "$arg"; done

bench-sp1-sha2-chain-precompile-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program sha2-chain-precompile && cd ..; done

bench-sp1-sha2-chain-precompile-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "sp1" "sha2-chain-precompile" "$arg"; done

bench-sp1-sha3-precompile-time:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program sha3-precompile && cd ..; done

bench-sp1-sha3-precompile-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "sp1" "sha3-precompile" "$arg"; done

bench-sp1-sha3-chain-precompile-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg "$arg" -- --program sha3-chain-precompile && cd ..; done

bench-sp1-sha3-chain-precompile-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "sp1" "sha3-chain-precompile" "$arg"; done

bench-sp1-sha3-time:
    -for arg in {{SHA_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg "$arg" -- --program sha3 && cd ..; done

bench-sp1-sha3-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "sp1" "sha3" "$arg"; done

bench-sp1-sha3-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg "$arg" -- --program sha3-chain && cd ..; done

bench-sp1-sha3-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "sp1" "sha3-chain" "$arg"; done

bench-sp1-mat-mul-time:
    -for arg in {{MATMUL_ARGS}}; do cd sp1 && ../utils/target/release/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg "$arg" -- --program mat-mul && cd ..; done

bench-sp1-mat-mul-mem:
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
    # cd risczero/ec && cargo build --release
    # cd risczero/ec-precompile && cargo build --release    
    cd risczero/mat-mul && cargo build --release

bench-risczero: build-risczero
    just bench-risczero-mem
    just bench-risczero-time

bench-risczero-time:
    just bench-risczero-fib-time
    just bench-risczero-sha2-time
    just bench-risczero-sha2-precompile-time
    just bench-risczero-sha3-time
    just bench-risczero-sha3-precompile-time
    # just bench-risczero-sha2-chain-time
    # just bench-risczero-sha2-chain-precompile-time
    just bench-risczero-sha3-chain-time
    just bench-risczero-sha3-chain-precompile-time
    # just bench-risczero-ec-time
    # just bench-risczero-ec-precompile-time
    just bench-risczero-mat-mul-time

bench-risczero-mem:
    just bench-risczero-fib-mem
    just bench-risczero-sha2-mem
    just bench-risczero-sha2-precompile-mem
    just bench-risczero-sha3-mem
    just bench-risczero-sha3-precompile-mem
    # just bench-risczero-sha2-chain-mem
    # just bench-risczero-sha2-chain-precompile-mem
    just bench-risczero-sha3-chain-mem
    just bench-risczero-sha3-chain-precompile-mem
    # just bench-risczero-ec-mem
    # just bench-risczero-ec-precompile-mem
    just bench-risczero-mat-mul-mem

bench-risczero-fib-mem:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "risczero" "fib" "$arg"; done

bench-risczero-fib-time:
    -for arg in {{FIB_ARGS}}; do cd risczero/fib && ../../utils/target/release/utils --bench-name risczero-fib --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-ec-mem:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "risczero" "ec" "$arg"; done

bench-risczero-ec-time:
    -for arg in {{EC_ARGS}}; do cd risczero/ec && ../../utils/target/release/utils --bench-name risczero-ec --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-ec-precompile-mem:
    -for arg in {{EC_ARGS}}; do ./bench_zkvm.sh "risczero" "ec-precompile" "$arg"; done

bench-risczero-ec-precompile-time:
    -for arg in {{EC_ARGS}}; do cd risczero/ec-precompile && ../../utils/target/release/utils --bench-name risczero-ec-precompile --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-mat-mul-mem:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "risczero" "mat-mul" "$arg"; done

bench-risczero-mat-mul-time:
    -for arg in {{MATMUL_ARGS}}; do cd risczero/mat-mul && ../../utils/target/release/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-sha2-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "risczero" "sha2" "$arg"; done

bench-risczero-sha2-time:
    -for arg in {{SHA_ARGS}}; do cd risczero/sha2 && ../../utils/target/release/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-sha2-precompile-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "risczero" "sha2-precompile" "$arg"; done

bench-risczero-sha2-precompile-time:
    -for arg in {{SHA_ARGS}}; do cd risczero/sha2-precompile && ../../utils/target/release/utils --bench-name risczero-sha2-precompile --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-sha2-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "risczero" "sha2-chain" "$arg"; done

bench-risczero-sha2-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd risczero/sha2-chain && ../../utils/target/release/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-sha2-chain-precompile-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "risczero" "sha2-chain-precompile" "$arg"; done

bench-risczero-sha2-chain-precompile-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd risczero/sha2-chain-precompile && ../../utils/target/release/utils --bench-name risczero-sha2-chain-precompile --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-sha3-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "risczero" "sha3" "$arg"; done

bench-risczero-sha3-time:
    -for arg in {{SHA_ARGS}}; do cd risczero/sha3 && ../../utils/target/release/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-sha3-precompile-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "risczero" "sha3-precompile" "$arg"; done

bench-risczero-sha3-precompile-time:
    -for arg in {{SHA_ARGS}}; do cd risczero/sha3-precompile && ../../utils/target/release/utils --bench-name risczero-sha3-precompile --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-sha3-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "risczero" "sha3-chain" "$arg"; done

bench-risczero-sha3-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd risczero/sha3-chain && ../../utils/target/release/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg "$arg" && cd ../..; done

bench-risczero-sha3-chain-precompile-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "risczero" "sha3-chain-precompile" "$arg"; done

bench-risczero-sha3-chain-precompile-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd risczero/sha3-chain-precompile && ../../utils/target/release/utils --bench-name risczero-sha3-chain-precompile --bin target/release/host --bench-arg "$arg" && cd ../..; done

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
    just bench-stone-mem
    just bench-stone-time

bench-stone-mem:
    just bench-stone-fib-mem
    just bench-stone-sha3-mem
    just bench-stone-sha3-builtin-mem
    just bench-stone-sha3-chain-builtin-mem
    just bench-stone-mat-mem
    just bench-stone-sha2-mem
    # just bench-stone-sha2-chain-mem

bench-stone-time:
    just bench-stone-fib-time
    just bench-stone-sha3-time
    just bench-stone-sha3-builtin-time
    just bench-stone-sha3-chain-builtin-time
    just bench-stone-mat-time
    just bench-stone-sha2-time
    # just bench-stone-sha2-chain-time


bench-stone-fib-time:
    -for arg in {{FIB_ARGS}}; do cd stone/fib && ../../utils/target/release/utils --bench-name stone-fib --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-fib-mem:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "stone" "fib" "$arg"; done

bench-stone-mat-time:
    -for arg in {{MATMUL_ARGS}}; do cd stone/mat-mul && ../../utils/target/release/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-mat-mem:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "stone" "mat-mul" "$arg"; done

bench-stone-sha3-time:
    -for arg in {{SHA_ARGS}}; do cd stone/sha3 && ../../utils/target/release/utils --bench-name stone-sha3 --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-sha3-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stone" "sha3" "$arg"; done

# representing bytes 200, 400, 1000, 2000
# as each iteration of the sha3 builtin processes 200 bytes
# let inputs = [1, 2, 5, 10];
bench-stone-sha3-builtin-time:
    -for arg in 1 2 5 10; do cd stone/sha3-builtin && ../../utils/target/release/utils --bench-name stone-sha3-builtin --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-sha3-builtin-mem:
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
bench-stone-sha3-chain-builtin-time:
    -for arg in 37 74 148 295 589; do cd stone/sha3-chain-builtin && ../../utils/target/release/utils --bench-name stone-sha3-chain-builtin --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-sha3-chain-builtin-mem:
    -for arg in 37 74 148 295 589; do ./bench_zkvm.sh "stone" "sha3-chain-builtin" "$arg"; done

bench-stone-sha2-time:
    -for arg in {{SHA_ARGS}}; do cd stone/sha2 && ../../utils/target/release/utils --bench-name stone-sha2 --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-sha2-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stone" "sha2" "$arg"; done

bench-stone-sha2-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd stone/sha2-chain && ../../utils/target/release/utils --bench-name stone-sha2-chain --bin target/release/stone --bench-arg "$arg" && cd ../..; done

bench-stone-sha2-chain-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stone" "sha2-chain" "$arg"; done


#####
# Stwo
#####

bench-stwo: build-stwo
    just bench-stwo-mem
    just bench-stwo-time

build-stwo:
    cd stwo && cargo build --release
    cd stwo/fib && scarb build
    cd stwo/mat_mul && scarb build
    -cd stwo && git clone https://github.com/starkware-libs/stwo-cairo.git && cd stwo-cairo && git checkout 36092a6f4c145b71fc275e3712e8df4df50b5dc6
    cd stwo/stwo-cairo/stwo_cairo_prover && cargo build --release

bench-stwo-mem:
    just bench-stwo-fib-mem
    just bench-stwo-sha2-mem
    just bench-stwo-sha3-mem
    just bench-stwo-sha3-chain-mem
    # just bench-stwo-sha2-chain-mem
    just bench-stwo-mat-mul-mem

bench-stwo-time:
    just bench-stwo-fib-time
    just bench-stwo-sha2-time
    just bench-stwo-sha3-time
    just bench-stwo-sha3-chain-time
    # just bench-stwo-sha2-chain-time
    just bench-stwo-mat-mul-time

bench-stwo-fib-mem:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "stwo" "fib" "$arg"; done

bench-stwo-sha2-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stwo" "sha2" "$arg"; done

bench-stwo-sha3-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "stwo" "sha3" "$arg"; done

bench-stwo-sha2-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "stwo" "sha2-chain" "$arg"; done

bench-stwo-sha3-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "stwo" "sha3-chain" "$arg"; done

bench-stwo-mat-mul-mem:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "stwo" "mat-mul" "$arg"; done

bench-stwo-fib-time:
    -for arg in {{FIB_ARGS}}; do cd stwo && ../utils/target/release/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg "$arg" -- --program fib && cd ..; done

bench-stwo-sha2-time:
    -for arg in {{SHA_ARGS}}; do cd stwo && ../utils/target/release/utils --bench-name stwo-sha2 --bin target/release/stwo-script --bench-arg "$arg" -- --program sha2 && cd ..; done

bench-stwo-sha3-time:
    -for arg in {{SHA_ARGS}}; do cd stwo && ../utils/target/release/utils --bench-name stwo-sha3 --bin target/release/stwo-script --bench-arg "$arg" -- --program sha3 && cd ..; done

bench-stwo-sha2-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd stwo && ../utils/target/release/utils --bench-name stwo-sha2-chain --bin target/release/stwo-script --bench-arg "$arg" -- --program sha2-chain && cd ..; done

bench-stwo-sha3-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd stwo && ../utils/target/release/utils --bench-name stwo-sha3-chain --bin target/release/stwo-script --bench-arg "$arg" -- --program sha3-chain && cd ..; done

bench-stwo-mat-mul-time:
    -for arg in {{MATMUL_ARGS}}; do cd stwo && ../utils/target/release/utils --bench-name stwo-mat-mul --bin target/release/stwo-script --bench-arg "$arg" -- --program mat-mul && cd ..; done


#####
# openvm
#####

build-openvm:
    cd openvm && rustup install
    cd openvm && cargo build --release

bench-openvm: build-openvm
    just bench-openvm-mem
    just bench-openvm-time

bench-openvm-mem:
    just bench-openvm-fib-mem
    just bench-openvm-sha2-mem
    # just bench-openvm-sha2-chain-mem
    just bench-openvm-sha3-mem
    just bench-openvm-sha3-chain-mem
    just bench-openvm-sha2-precompile-mem
    # just bench-openvm-sha2-chain-precompile-mem
    just bench-openvm-sha3-precompile-mem
    just bench-openvm-sha3-chain-precompile-mem
    just bench-openvm-mat-mul-mem

bench-openvm-time:
    just bench-openvm-fib-time
    just bench-openvm-sha2-time
    # just bench-openvm-sha2-chain-time
    just bench-openvm-sha3-time
    just bench-openvm-sha3-chain-time
    just bench-openvm-sha2-precompile-time
    # just bench-openvm-sha2-chain-precompile-time
    just bench-openvm-sha3-precompile-time
    just bench-openvm-sha3-chain-precompile-time
    just bench-openvm-mat-mul-time

bench-openvm-fib-time:
    -for arg in {{FIB_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-fib --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program fib && cd ..; done

bench-openvm-fib-mem:
    -for arg in {{FIB_ARGS}}; do ./bench_zkvm.sh "openvm" "fib" "$arg"; done

bench-openvm-sha2-time:
    -for arg in {{SHA_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-sha2 --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program sha2 && cd ..; done

bench-openvm-sha2-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "openvm" "sha2" "$arg"; done

bench-openvm-sha2-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-sha2-chain --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program sha2-chain && cd ..; done

bench-openvm-sha2-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "openvm" "sha2-chain" "$arg"; done

bench-openvm-sha3-time:
    -for arg in {{SHA_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-sha3 --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program sha3 && cd ..; done

bench-openvm-sha3-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "openvm" "sha3" "$arg"; done

bench-openvm-sha3-chain-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-sha3-chain --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program sha3-chain && cd ..; done

bench-openvm-sha3-chain-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "openvm" "sha3-chain" "$arg"; done

bench-openvm-mat-mul-time:
	-for arg in {{MATMUL_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-mat-mul --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program mat-mul && cd ..; done

bench-openvm-mat-mul-mem:
    -for arg in {{MATMUL_ARGS}}; do ./bench_zkvm.sh "openvm" "mat-mul" "$arg"; done

bench-openvm-sha2-precompile-time:
    -for arg in {{SHA_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-sha2-precompile --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program sha2-precompile && cd ..; done

bench-openvm-sha2-precompile-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "openvm" "sha2-precompile" "$arg"; done

bench-openvm-sha2-chain-precompile-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-sha2-chain-precompile --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program sha2-chain-precompile && cd ..; done

bench-openvm-sha2-chain-precompile-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "openvm" "sha2-chain-precompile" "$arg"; done

bench-openvm-sha3-precompile-time:
    -for arg in {{SHA_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-sha3-precompile --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program sha3-precompile && cd ..; done

bench-openvm-sha3-precompile-mem:
    -for arg in {{SHA_ARGS}}; do ./bench_zkvm.sh "openvm" "sha3-precompile" "$arg"; done

bench-openvm-sha3-chain-precompile-time:
    -for arg in {{SHA_CHAIN_ARGS}}; do cd openvm && ../utils/target/release/utils --bench-name openvm-sha3-chain-precompile --bin target/release/openvm-benchmarks --bench-arg "$arg" -- --program sha3-chain-precompile && cd ..; done

bench-openvm-sha3-chain-precompile-mem:
    -for arg in {{SHA_CHAIN_ARGS}}; do ./bench_zkvm.sh "openvm" "sha3-chain-precompile" "$arg"; done
