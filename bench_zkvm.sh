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

# Determine BENCH_BIN and COMMAND based on BENCH_ZKVM
if [ "$BENCH_ZKVM" == "risczero" ]; then
    BENCH_BIN="target/release/host"
    COMMAND="./mem.sh bash -c 'cd $BENCH_DIR && ../../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG'"
else
    BENCH_BIN="../target/release/sp1-script"
    COMMAND="./mem.sh bash -c 'cd $BENCH_DIR && ../../utils/target/release/utils --bench-name $BENCH_ZKVM_NAME --bin $BENCH_BIN --bench-arg $BENCH_ARG -- --program $BENCH_NAME'"
fi

# Print results (optional, for debugging)
echo "BENCH_ZKVM: $BENCH_ZKVM"
echo "BENCH_NAME: $BENCH_NAME"
echo "BENCH_ARG: $BENCH_ARG"
echo "CSV_FILE: $CSV_FILE"
echo "BENCH_DIR: $BENCH_DIR"
echo "BENCH_BIN: $BENCH_BIN"
echo "COMMAND: $COMMAND"

# Run the command and capture output
echo "Running command..."
eval $COMMAND > "$TMP_FILE" 2>&1

# Extract the peak memory value
PEAK_MEMORY_MB=$(grep -oP 'Maximum memory usage: \K[0-9.]+' "$TMP_FILE")

# Check if peak memory was found
if [ -z "$PEAK_MEMORY_MB" ]; then
    echo "Error: Could not extract peak memory value from command output."
    exit 1
fi

# Convert peak memory from MB to GB (1 GB = 1024 MB)
PEAK_MEMORY_GB=$(echo "scale=2; $PEAK_MEMORY_MB / 1024" | bc)

echo "Extracted peak memory: $PEAK_MEMORY_GB GB"

# Update the CSV file
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: File $CSV_FILE not found."
    exit 1
fi

awk -v peak_memory="$PEAK_MEMORY_GB" -v row_id="$ROW_IDENTIFIER" -F, '
BEGIN { OFS = FS } 
{
    # If the first column matches the row identifier, update the last column
    if ($1 == row_id) {
        $6 = peak_memory;
    }
    print $0;
}' "$CSV_FILE" > temp.csv && mv temp.csv "$CSV_FILE"

echo "Updated $CSV_FILE with peak memory $PEAK_MEMORY_GB GB for row $ROW_IDENTIFIER."

# Clean up temporary file
rm -f "$TMP_FILE"
