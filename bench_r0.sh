#!/bin/bash

# Check if enough arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 '<bench_name>' <bench_arg>"
    exit 1
fi

# Variables
BENCH_NAME="$1"
BENCH_ARG="$2"
ROW_IDENTIFIER=$BENCH_ARG
CSV_FILE="benchmark_outputs/risczero-$BENCH_NAME.csv"
BENCH_DIR="risczero/$BENCH_NAME"
TMP_FILE="tmp_output.txt"
R0_BENCH_NAME="risczero-$BENCH_NAME"

# Print results (optional, for debugging)
echo "BENCH_NAME: $BENCH_NAME"
echo "BENCH_ARG: $BENCH_ARG"
echo "CSV_FILE: $CSV_FILE"
echo "BENCH_DIR: $BENCH_DIR"

# Run the command and capture output
echo "Running command..."
./mem.sh bash -c "cd $BENCH_DIR && ../../utils/target/debug/utils --bench-name $R0_BENCH_NAME --bin target/release/host --bench-arg $BENCH_ARG" > "$TMP_FILE" 2>&1

# Extract the peak memory value
PEAK_MEMORY=$(grep -oP 'Maximum memory usage: \K[0-9.]+ MB' "$TMP_FILE")

# Check if peak memory was found
if [ -z "$PEAK_MEMORY" ]; then
    echo "Error: Could not extract peak memory value from command output."
    exit 1
fi

echo "Extracted peak memory: $PEAK_MEMORY"

# Update the CSV file
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: File $CSV_FILE not found."
    exit 1
fi

awk -v peak_memory="$PEAK_MEMORY" -v row_id="$ROW_IDENTIFIER" -F, '
BEGIN { OFS = FS } 
{
    # If the first column matches the row identifier, update the last column
    if ($1 == row_id) {
        $6 = peak_memory;
    }
    print $0;
}' "$CSV_FILE" > temp.csv && mv temp.csv "$CSV_FILE"

echo "Updated $CSV_FILE with peak memory $PEAK_MEMORY for row $ROW_IDENTIFIER."

# Clean up temporary file
rm -f "$TMP_FILE"
