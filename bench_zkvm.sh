#!/bin/bash

# Check if enough arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <bench_zkvm> '<bench_name>' <bench_arg>"
    exit 1
fi

# Variables
BENCH_ZKVM="$1"
BENCH_NAME="$2"
BENCH_ARG="$3"
ROW_IDENTIFIER=$BENCH_ARG
CSV_FILE="benchmark_outputs/${BENCH_ZKVM}-${BENCH_NAME}.csv"
BENCH_DIR="${BENCH_ZKVM}/${BENCH_NAME}"
TMP_FILE="tmp_output.txt"
BENCH_ZKVM_NAME="${BENCH_ZKVM}-${BENCH_NAME}"
MEM_DIR="./memory_outputs"
mkdir -p $MEM_DIR
BENCH_OUT="${MEM_DIR}/${BENCH_ZKVM}_${BENCH_NAME}_${BENCH_ARG}.txt"

# Determine BENCH_BIN and COMMAND based on BENCH_ZKVM
if [ "$BENCH_ZKVM" == "risczero" ]; then
    BENCH_BIN="target/release/host"
    COMMAND="sudo ./memuse $BENCH_OUT 'cd $BENCH_DIR && ../../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG'"
elif [ "$BENCH_ZKVM" == "sp1" ]; then
    BENCH_BIN="../target/release/sp1-script"
    COMMAND="sudo ./memuse $BENCH_OUT 'cd $BENCH_DIR && ../../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG -- --program $BENCH_NAME'"
elif [ "$BENCH_ZKVM" == "jolt" ]; then
    BENCH_BIN="target/release/jolt-benchmarks"
    COMMAND="sudo ./memuse $BENCH_OUT 'cd $BENCH_ZKVM && ../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG -- --program $BENCH_NAME'"
elif [ "$BENCH_ZKVM" == "stwo" ]; then
    BENCH_BIN="target/release/stwo-script"
    COMMAND="sudo ./memuse $BENCH_OUT 'cd $BENCH_ZKVM && ../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG -- --program $BENCH_NAME'"
elif [ "$BENCH_ZKVM" == "stone" ]; then
    BENCH_BIN="target/release/stone"
    COMMAND="sudo ./memuse $BENCH_OUT 'cd $BENCH_DIR && ../../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG'"
else
    echo "Error: Unknown zkVM '$BENCH_ZKVM'"
    exit 1
fi

# Print info
echo "BENCH_ZKVM: $BENCH_ZKVM"
echo "BENCH_NAME: $BENCH_NAME"
echo "BENCH_ARG: $BENCH_ARG"
echo "CSV_FILE: $CSV_FILE"
echo "BENCH_DIR: $BENCH_DIR"
echo "BENCH_BIN: $BENCH_BIN"
echo "COMMAND: $COMMAND"

# Run the benchmark
echo "Running benchmark..."
eval "$COMMAND"

# Extract peak memory
if [ -f "$BENCH_OUT" ]; then
    PEAK_MEMORY_BYTES=$(awk 'BEGIN { max = 0 } { if ($2 > max) max = $2 } END { print max }' "$BENCH_OUT")
    echo "PEAK_MEMORY_BYTES: $PEAK_MEMORY_BYTES"
else
    echo "Error: Benchmark output file not found at $BENCH_OUT"
    exit 1
fi

# Convert bytes to GB (1 GB = 1024 * 1024 * 1024 bytes)
PEAK_MEMORY_GB=$(echo "scale=2; $PEAK_MEMORY_BYTES / (1024 * 1024 * 1024)" | bc)

echo "Extracted peak memory: $PEAK_MEMORY_GB GB"

# Update the CSV file
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file $CSV_FILE not found."
    exit 1
fi

awk -v peak_memory="$PEAK_MEMORY_GB" -v row_id="$ROW_IDENTIFIER" -F, '
BEGIN { OFS = FS } 
{
    if ($1 == row_id) {
        $6 = peak_memory;
    }
    print
}' "$CSV_FILE" > tmp_csv_update.csv && mv tmp_csv_update.csv "$CSV_FILE"

echo "Updated $CSV_FILE with peak memory $PEAK_MEMORY_GB GB for row $ROW_IDENTIFIER."
