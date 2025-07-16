export PATH := env_var('HOME') + "/.rustup:" + env_var('HOME') + "/.cargo/bin:" + env_var('HOME') + "/.risc0/bin:" + env_var('HOME') + "/.sp1/bin:" + env_var('HOME') + "/.local/bin:" + env_var('PATH')

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

# Capture machine information
machine-info:
    ./scripts/machine_info.sh

# Build utilities
build-utils:
    cd utils && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

# Build memuse program
build-memuse:
    gcc ./scripts/memuse.c -o memuse

# Activate venv and run benchmark with memory monitoring
run-bench zkvm benchmark arg verifier_iterations="1":
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Activate venv
    VENV_PATH="$HOME/bench-venv"
    source "$VENV_PATH/bin/activate"
    
    # Variables
    BENCH_ZKVM="{{zkvm}}"
    BENCH_NAME="{{benchmark}}"
    BENCH_ARG="{{arg}}"
    VERIFIER_ITERATIONS="{{verifier_iterations}}"
    CSV_FILE="benchmark_outputs/${BENCH_ZKVM}-${BENCH_NAME}.csv"
    BENCH_DIR="${BENCH_ZKVM}/${BENCH_NAME}"
    BENCH_ZKVM_NAME="${BENCH_ZKVM}-${BENCH_NAME}"
    MEM_DIR="./memory_outputs"
    mkdir -p $MEM_DIR
    BENCH_OUT="${MEM_DIR}/${BENCH_ZKVM}_${BENCH_NAME}_${BENCH_ARG}.txt"
    
    # Determine BENCH_BIN and COMMAND based on BENCH_ZKVM
    if [ "$BENCH_ZKVM" == "risczero" ]; then
        BENCH_BIN="target/release/host"
        COMMAND="sudo HOME=$HOME PATH=$PATH ./memuse $BENCH_OUT 'cd $BENCH_DIR && ../../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG --verifier-iterations $VERIFIER_ITERATIONS'"
    elif [ "$BENCH_ZKVM" == "sp1" ]; then
        BENCH_BIN="../target/release/sp1-script"
        COMMAND="sudo HOME=$HOME PATH=$PATH ./memuse $BENCH_OUT 'cd $BENCH_DIR && ../../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG --verifier-iterations $VERIFIER_ITERATIONS -- --program $BENCH_NAME'"
    elif [ "$BENCH_ZKVM" == "jolt" ]; then
        BENCH_BIN="target/release/jolt-benchmarks"
        COMMAND="sudo HOME=$HOME PATH=$PATH ./memuse $BENCH_OUT 'cd $BENCH_ZKVM && ../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG --verifier-iterations $VERIFIER_ITERATIONS -- --program $BENCH_NAME'"
    elif [ "$BENCH_ZKVM" == "stwo" ]; then
        BENCH_BIN="target/release/stwo-script"
        COMMAND="sudo HOME=$HOME PATH=$PATH ./memuse $BENCH_OUT 'cd $BENCH_ZKVM && ../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG --verifier-iterations $VERIFIER_ITERATIONS -- --program $BENCH_NAME'"
    elif [ "$BENCH_ZKVM" == "stone" ]; then
        BENCH_BIN="target/release/stone"
        COMMAND="sudo SHARP_CLIENT_CERT=$SHARP_CLIENT_CERT SHARP_KEY_PATH=$SHARP_KEY_PATH SHARP_KEY_PASSWD=$SHARP_KEY_PASSWD HOME=$HOME PATH=$PATH ./memuse $BENCH_OUT 'cd $BENCH_DIR && ../../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG --verifier-iterations $VERIFIER_ITERATIONS'"
    elif [ "$BENCH_ZKVM" == "openvm" ]; then
        BENCH_BIN="target/release/openvm-benchmarks"
        COMMAND="sudo HOME=$HOME PATH=$PATH ./memuse $BENCH_OUT 'cd $BENCH_ZKVM && ../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG --verifier-iterations $VERIFIER_ITERATIONS -- --program $BENCH_NAME'"
    else
        echo "Error: Unknown zkVM '$BENCH_ZKVM'"
        exit 1
    fi
    
    # Print info
    echo "BENCH_ZKVM: $BENCH_ZKVM"
    echo "BENCH_NAME: $BENCH_NAME"
    echo "BENCH_ARG: $BENCH_ARG"
    echo "VERIFIER_ITERATIONS: $VERIFIER_ITERATIONS"
    echo "CSV_FILE: $CSV_FILE"
    echo "BENCH_DIR: $BENCH_DIR"
    echo "BENCH_BIN: $BENCH_BIN"
    echo "COMMAND: $COMMAND"
    
    # Run the benchmark
    echo "Running benchmark..."
    eval "$COMMAND"
    
    # Extract peak memory
    if [ -f "$BENCH_OUT" ]; then
        PEAK_MEMORY_BYTES=$(grep "PEAK" "$BENCH_OUT" | awk '{print $2}')
        echo "PEAK_MEMORY_BYTES: $PEAK_MEMORY_BYTES"
    else
        echo "Error: Benchmark output file not found at $BENCH_OUT"
        exit 1
    fi
    
    # Convert bytes to GB
    PEAK_MEMORY_GB=$(echo "scale=2; $PEAK_MEMORY_BYTES / (1024 * 1024 * 1024)" | bc)
    echo "Extracted peak memory: $PEAK_MEMORY_GB GB"
    
    # Update the CSV file
    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: CSV file $CSV_FILE not found."
        exit 1
    fi
    
    awk -v peak_memory="$PEAK_MEMORY_GB" -v row_id="$BENCH_ARG" -F, '
    BEGIN { OFS = FS } 
    {
        if ($1 == row_id) {
            $6 = peak_memory;
        }
        print
    }' "$CSV_FILE" > tmp_csv_update.csv && mv tmp_csv_update.csv "$CSV_FILE"
    
    echo "Updated $CSV_FILE with peak memory $PEAK_MEMORY_GB GB for row $BENCH_ARG."

# Bench local
bench-local: build-utils build-memuse machine-info
    just bench-stwo      "{{FIB_ARG_LOCAL}}" "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"
    just bench-jolt      "{{FIB_ARG_LOCAL}}" "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"
    just bench-sp1       "{{FIB_ARG_LOCAL}}" "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"
    just bench-risczero  "{{FIB_ARG_LOCAL}}" "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"
    just bench-openvm    "{{FIB_ARG_LOCAL}}" "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"


#####
# jolt
#####

build-jolt: build-utils
    cd jolt && rustup install
    cd jolt && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

# bench-all takes arguments for all benchmarks
bench-jolt fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: build-jolt
    just bench-jolt-fib "{{fib_args}}"
    just bench-jolt-sha2 "{{sha2_args}}"
    just bench-jolt-sha2-chain "{{sha2_chain_args}}"
    just bench-jolt-sha3 "{{sha3_args}}"
    just bench-jolt-sha3-chain "{{sha3_chain_args}}"
    just bench-jolt-mat-mul "{{matmul_args}}"
    just bench-jolt-ec "{{ec_args}}"

bench-jolt-fib fib_args verifier_iterations="1":
    -for arg in {{fib_args}}; do just run-bench "jolt" "fib" "$arg" "{{verifier_iterations}}"; done

bench-jolt-sha2 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench "jolt" "sha2" "$arg" "{{verifier_iterations}}"; done

bench-jolt-sha2-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do just run-bench "jolt" "sha2-chain" "$arg" "{{verifier_iterations}}"; done

bench-jolt-sha3 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench "jolt" "sha3" "$arg" "{{verifier_iterations}}"; done

bench-jolt-sha3-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do just run-bench "jolt" "sha3-chain" "$arg" "{{verifier_iterations}}"; done

bench-jolt-mat-mul matmul_args verifier_iterations="1":
    -for arg in {{matmul_args}}; do just run-bench "jolt" "mat-mul" "$arg" "{{verifier_iterations}}"; done

bench-jolt-ec ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do just run-bench "jolt" "ec" "$arg" "{{verifier_iterations}}"; done


#####
# sp1
#####

build-sp1: build-utils
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

bench-sp1 fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: build-sp1
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

build-risczero: build-utils
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

bench-risczero fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: build-risczero
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

build-stone: build-utils
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

bench-stone fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: build-stone
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

build-stwo: build-utils
    cd stwo && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-stwo fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: build-stwo
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

build-openvm: build-utils
    cd openvm && rustup install
    cd openvm && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-openvm fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: build-openvm
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