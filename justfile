export PATH := env_var('HOME') + "/.rustup:" + \
    env_var('HOME') + "/.cargo/bin:" + \
    env_var('HOME') + "/.risc0/bin:" + \
    env_var('HOME') + "/.sp1/bin:" + \
    env_var('HOME') + "/.local/bin:" + \
    env_var('PATH')

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

# Run command with memory monitoring and update CSV
run-with-memory zkvm benchmark arg command env_vars="":
    #!/usr/bin/env bash
    set -euo pipefail
    source "$HOME/bench-venv/bin/activate"
    mkdir -p memory_outputs
    
    # Run benchmark with memory monitoring
    MEMORY_FILE="memory_outputs/{{zkvm}}_{{benchmark}}_{{arg}}.txt"
    sudo {{env_vars}} HOME=$HOME PATH=$PATH ./memuse "$MEMORY_FILE" '{{command}}'
    
    # Extract peak memory and update CSV
    CSV_FILE="benchmark_outputs/{{zkvm}}-{{benchmark}}.csv"
    if [ ! -f "$MEMORY_FILE" ]; then
        echo "Error: Memory output file not found at $MEMORY_FILE"
        exit 1
    fi
    
    PEAK_MEMORY_BYTES=$(grep "PEAK" "$MEMORY_FILE" | awk '{print $2}')
    echo "PEAK_MEMORY_BYTES: $PEAK_MEMORY_BYTES"
    
    # Update the CSV file
    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: CSV file $CSV_FILE not found."
        exit 1
    fi
    
    awk -v peak_memory="$PEAK_MEMORY_BYTES" -v row_id="{{arg}}" -F, '
    BEGIN { OFS = FS } 
    {
        if ($1 == row_id) {
            $6 = peak_memory;
        }
        print
    }' "$CSV_FILE" > tmp_csv_update.csv && mv tmp_csv_update.csv "$CSV_FILE"
    
    echo "Updated $CSV_FILE with peak memory $PEAK_MEMORY_BYTES bytes for row {{arg}}."

# Run risczero benchmark with memory monitoring
run-bench-risczero benchmark arg verifier_iterations="1":
    just run-with-memory "risczero" "{{benchmark}}" "{{arg}}" \
        "cd risczero/{{benchmark}} && \
         ../../utils/target/release/utils \
         --bench-name risczero-{{benchmark}} \
         --bin target/release/host \
         --bench-arg {{arg}} \
         --verifier-iterations {{verifier_iterations}}"

# Run sp1 benchmark with memory monitoring
run-bench-sp1 benchmark arg verifier_iterations="1":
    just run-with-memory "sp1" "{{benchmark}}" "{{arg}}" \
        "cd sp1/{{benchmark}} && \
         ../../utils/target/release/utils \
         --bench-name sp1-{{benchmark}} \
         --bin ../target/release/sp1-script \
         --bench-arg {{arg}} \
         --verifier-iterations {{verifier_iterations}} \
         -- --program {{benchmark}}"

# Run jolt benchmark with memory monitoring
run-bench-jolt benchmark arg verifier_iterations="1":
    just run-with-memory "jolt" "{{benchmark}}" "{{arg}}" \
        "cd jolt && \
         ../utils/target/release/utils \
         --bench-name jolt-{{benchmark}} \
         --bin target/release/jolt-benchmarks \
         --bench-arg {{arg}} \
         --verifier-iterations {{verifier_iterations}} \
         -- --program {{benchmark}}"

# Run stwo benchmark with memory monitoring
run-bench-stwo benchmark arg verifier_iterations="1":
    just run-with-memory "stwo" "{{benchmark}}" "{{arg}}" \
        "cd stwo && \
         ../utils/target/release/utils \
         --bench-name stwo-{{benchmark}} \
         --bin target/release/stwo-script \
         --bench-arg {{arg}} \
         --verifier-iterations {{verifier_iterations}} \
         -- --program {{benchmark}}"

# Run stone benchmark with memory monitoring
run-bench-stone benchmark arg verifier_iterations="1":
    just run-with-memory "stone" "{{benchmark}}" "{{arg}}" \
        "cd stone/{{benchmark}} && \
         ../../utils/target/release/utils \
         --bench-name stone-{{benchmark}} \
         --bin target/release/stone \
         --bench-arg {{arg}} \
         --verifier-iterations {{verifier_iterations}}" \
        "SHARP_CLIENT_CERT=$SHARP_CLIENT_CERT \
         SHARP_KEY_PATH=$SHARP_KEY_PATH \
         SHARP_KEY_PASSWD=$SHARP_KEY_PASSWD"

# Run openvm benchmark with memory monitoring
run-bench-openvm benchmark arg verifier_iterations="1":
    just run-with-memory "openvm" "{{benchmark}}" "{{arg}}" \
        "cd openvm && \
         ../utils/target/release/utils \
         --bench-name openvm-{{benchmark}} \
         --bin target/release/openvm-benchmarks \
         --bench-arg {{arg}} \
         --verifier-iterations {{verifier_iterations}} \
         -- --program {{benchmark}}"

# Bench local
bench-local: build-utils build-memuse machine-info
    just bench-stwo \
        "{{FIB_ARG_LOCAL}}" \
        "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" \
        "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" \
        "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"

    just bench-jolt \
        "{{FIB_ARG_LOCAL}}" \
        "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" \
        "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" \
        "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"

    just bench-sp1 \
        "{{FIB_ARG_LOCAL}}" \
        "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" \
        "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" \
        "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"

    just bench-risczero \
        "{{FIB_ARG_LOCAL}}" \
        "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" \
        "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" \
        "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"

    just bench-openvm \
        "{{FIB_ARG_LOCAL}}" \
        "{{SHA2_ARG_LOCAL}}" "{{SHA2_CHAIN_ARG_LOCAL}}" \
        "{{SHA3_ARG_LOCAL}}" "{{SHA3_CHAIN_ARG_LOCAL}}" \
        "{{MATMUL_ARG_LOCAL}}" "{{EC_ARG_LOCAL}}"

#####
# jolt
#####

build-jolt: build-utils
    cd jolt && rustup install
    cd jolt && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

# bench-all takes arguments for all benchmarks
bench-jolt fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: \
    build-jolt
    just bench-jolt-fib "{{fib_args}}"
    just bench-jolt-sha2 "{{sha2_args}}"
    just bench-jolt-sha2-chain "{{sha2_chain_args}}"
    just bench-jolt-sha3 "{{sha3_args}}"
    just bench-jolt-sha3-chain "{{sha3_chain_args}}"
    just bench-jolt-mat-mul "{{matmul_args}}"
    just bench-jolt-ec "{{ec_args}}"

bench-jolt-fib fib_args verifier_iterations="1":
    -for arg in {{fib_args}}; do just run-bench-jolt "fib" "$arg" "{{verifier_iterations}}"; done

bench-jolt-sha2 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench-jolt "sha2" "$arg" "{{verifier_iterations}}"; done

bench-jolt-sha2-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-jolt "sha2-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-jolt-sha3 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench-jolt "sha3" "$arg" "{{verifier_iterations}}"; done

bench-jolt-sha3-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-jolt "sha3-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-jolt-mat-mul matmul_args verifier_iterations="1":
    -for arg in {{matmul_args}}; do \
        just run-bench-jolt "mat-mul" "$arg" "{{verifier_iterations}}"; \
    done

bench-jolt-ec ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do just run-bench-jolt "ec" "$arg" "{{verifier_iterations}}"; done


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

bench-sp1 fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: \
    build-sp1
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

bench-sp1-fib fib_args verifier_iterations="1":
    -for arg in {{fib_args}}; do just run-bench-sp1 "fib" "$arg" "{{verifier_iterations}}"; done

bench-sp1-sha2 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench-sp1 "sha2" "$arg" "{{verifier_iterations}}"; done

bench-sp1-sha2-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-sp1 "sha2-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-sp1-sha2-precompile sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-sp1 "sha2-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-sp1-sha2-chain-precompile sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-sp1 "sha2-chain-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-sp1-sha3-precompile sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-sp1 "sha3-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-sp1-sha3-chain-precompile sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-sp1 "sha3-chain-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-sp1-sha3 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench-sp1 "sha3" "$arg" "{{verifier_iterations}}"; done

bench-sp1-sha3-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-sp1 "sha3-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-sp1-mat-mul matmul_args verifier_iterations="1":
    -for arg in {{matmul_args}}; do \
        just run-bench-sp1 "mat-mul" "$arg" "{{verifier_iterations}}"; \
    done

bench-sp1-ec ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do just run-bench-sp1 "ec" "$arg" "{{verifier_iterations}}"; done

bench-sp1-ec-precompile ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do \
        just run-bench-sp1 "ec-precompile" "$arg" "{{verifier_iterations}}"; \
    done


#####
# risczero
#####

build-risczero: build-utils
    cd risczero/fib && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha2 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha2-precompile && \
        RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha3 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha3-precompile && \
        RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha2-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha2-chain-precompile && \
        RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha3-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/sha3-chain-precompile && \
        RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/ec && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd risczero/ec-precompile && \
        RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release    
    cd risczero/mat-mul && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-risczero fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: \
    build-risczero
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

bench-risczero-fib fib_args verifier_iterations="1":
    -for arg in {{fib_args}}; do \
        just run-bench-risczero "fib" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-mat-mul matmul_args verifier_iterations="1":
    -for arg in {{matmul_args}}; do \
        just run-bench-risczero "mat-mul" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-sha2 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-risczero "sha2" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-sha2-precompile sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-risczero "sha2-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-sha2-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-risczero "sha2-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-sha2-chain-precompile sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-risczero "sha2-chain-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-sha3 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-risczero "sha3" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-sha3-precompile sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-risczero "sha3-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-sha3-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-risczero "sha3-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-sha3-chain-precompile sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-risczero "sha3-chain-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-risczero-ec ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do just run-bench-risczero "ec" "$arg" "{{verifier_iterations}}"; done

bench-risczero-ec-precompile ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do \
        just run-bench-risczero "ec-precompile" "$arg" "{{verifier_iterations}}"; \
    done

#####
# Stone
#####

build-stone: build-utils
    cd stone/common && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/fib && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha3 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha3-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha3-builtin && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha3-chain-builtin && \
        RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha2 && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/sha2-chain && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/mat-mul && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release
    cd stone/ec && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-stone fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: \
    build-stone
    just bench-stone-fib "{{fib_args}}"
    just bench-stone-sha3 "{{sha3_args}}"
    just bench-stone-sha3-chain "{{sha3_chain_args}}"
    just bench-stone-sha3-builtin "{{sha3_args}}"
    just bench-stone-sha3-chain-builtin "{{sha3_chain_args}}"
    just bench-stone-mat "{{matmul_args}}"
    just bench-stone-sha2 "{{sha2_args}}"
    just bench-stone-sha2-chain "{{sha2_chain_args}}"
    just bench-stone-ec "{{ec_args}}"

bench-stone-fib fib_args verifier_iterations="1":
    -for arg in {{fib_args}}; do just run-bench-stone "fib" "$arg" "{{verifier_iterations}}"; done

bench-stone-mat matmul_args verifier_iterations="1":
    -for arg in {{matmul_args}}; do \
        just run-bench-stone "mat-mul" "$arg" "{{verifier_iterations}}"; \
    done

bench-stone-sha3 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench-stone "sha3" "$arg" "{{verifier_iterations}}"; done

bench-stone-sha3-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-stone "sha3-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-stone-sha3-builtin sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-stone "sha3-builtin" "$arg" "{{verifier_iterations}}"; \
    done

bench-stone-sha3-chain-builtin sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-stone "sha3-chain-builtin" "$arg" "{{verifier_iterations}}"; \
    done

bench-stone-sha2 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench-stone "sha2" "$arg" "{{verifier_iterations}}"; done

bench-stone-sha2-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-stone "sha2-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-stone-ec ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do just run-bench-stone "ec" "$arg" "{{verifier_iterations}}"; done


#####
# Stwo
#####

build-stwo: build-utils
    cd stwo && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-stwo fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: \
    build-stwo
    just bench-stwo-fib "{{fib_args}}"
    just bench-stwo-sha2 "{{sha2_args}}"
    just bench-stwo-sha2-chain "{{sha2_chain_args}}"
    just bench-stwo-sha3 "{{sha3_args}}"
    just bench-stwo-sha3-chain "{{sha3_chain_args}}"
    just bench-stwo-mat-mul "{{matmul_args}}"
    just bench-stwo-ec "{{ec_args}}"

bench-stwo-fib fib_args verifier_iterations="1":
    -for arg in {{fib_args}}; do just run-bench-stwo "fib" "$arg" "{{verifier_iterations}}"; done

bench-stwo-sha2 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench-stwo "sha2" "$arg" "{{verifier_iterations}}"; done

bench-stwo-sha2-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-stwo "sha2-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-stwo-sha3 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do just run-bench-stwo "sha3" "$arg" "{{verifier_iterations}}"; done

bench-stwo-sha3-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-stwo "sha3-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-stwo-mat-mul matmul_args verifier_iterations="1":
    -for arg in {{matmul_args}}; do \
        just run-bench-stwo "mat-mul" "$arg" "{{verifier_iterations}}"; \
    done

bench-stwo-ec ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do just run-bench-stwo "ec" "$arg" "{{verifier_iterations}}"; done


#####
# openvm
#####

build-openvm: build-utils
    cd openvm && rustup install
    cd openvm && RUSTFLAGS="-C target-cpu=native -C opt-level=3" cargo build --release

bench-openvm fib_args sha2_args sha2_chain_args sha3_args sha3_chain_args matmul_args ec_args: \
    build-openvm
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

bench-openvm-fib fib_args verifier_iterations="1":
    -for arg in {{fib_args}}; do just run-bench-openvm "fib" "$arg" "{{verifier_iterations}}"; done

bench-openvm-sha2 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-openvm "sha2" "$arg" "{{verifier_iterations}}"; \
    done

bench-openvm-sha2-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-openvm "sha2-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-openvm-sha3 sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-openvm "sha3" "$arg" "{{verifier_iterations}}"; \
    done

bench-openvm-sha3-chain sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-openvm "sha3-chain" "$arg" "{{verifier_iterations}}"; \
    done

bench-openvm-mat-mul matmul_args verifier_iterations="1":
    -for arg in {{matmul_args}}; do \
        just run-bench-openvm "mat-mul" "$arg" "{{verifier_iterations}}"; \
    done

bench-openvm-sha2-precompile sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-openvm "sha2-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-openvm-sha2-chain-precompile sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-openvm "sha2-chain-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-openvm-sha3-precompile sha_args verifier_iterations="1":
    -for arg in {{sha_args}}; do \
        just run-bench-openvm "sha3-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-openvm-sha3-chain-precompile sha_chain_args verifier_iterations="1":
    -for arg in {{sha_chain_args}}; do \
        just run-bench-openvm "sha3-chain-precompile" "$arg" "{{verifier_iterations}}"; \
    done

bench-openvm-ec ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do just run-bench-openvm "ec" "$arg" "{{verifier_iterations}}"; done

bench-openvm-ec-precompile ec_args verifier_iterations="1":
    -for arg in {{ec_args}}; do \
        just run-bench-openvm "ec-precompile" "$arg" "{{verifier_iterations}}"; \
    done
