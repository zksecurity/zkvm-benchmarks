#!/bin/bash

# Check if enough arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 '<command>' <csv_file> <row_identifier>"
    exit 1
fi

# Variables
COMMAND="$1"
CSV_FILE="$2"
ROW_IDENTIFIER="$3"
TMP_FILE="tmp_output.txt"

# Run the command and capture output
echo "Running command..."
eval $COMMAND > "$TMP_FILE" 2>&1

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

