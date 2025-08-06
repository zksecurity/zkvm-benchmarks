#!/bin/bash

set -e

echo "Capturing Machine Info..."

whoami

OS_TYPE=$(uname)

# Capture Machine Info
REPORT_INFO_DIR="./report_info"
mkdir -p $REPORT_INFO_DIR


echo "Capturing CPU information..."
echo "=== CPU Information ===" > $REPORT_INFO_DIR/cpuinfo.txt
if [[ "$OS_TYPE" == "Linux" ]]; then
    lscpu >> $REPORT_INFO_DIR/cpuinfo.txt
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    sysctl -a | grep machdep.cpu >> $REPORT_INFO_DIR/cpuinfo.txt
else
    echo "Unknown OS for CPU info"
    exit 1
fi

echo "Capturing OS version information..."
if [[ "$OS_TYPE" == "Linux" && -f /etc/os-release ]]; then
    echo "=== OS Information ===" > $REPORT_INFO_DIR/os_version.txt
    cat /etc/os-release >> $REPORT_INFO_DIR/os_version.txt
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    sw_vers > $REPORT_INFO_DIR/os_version.txt
else
    echo "OS information file not found."
    exit 1
fi

echo "Capturing memory information..."
if [[ "$OS_TYPE" == "Linux" && -f /proc/meminfo ]]; then
    echo "=== Memory Information ===" > $REPORT_INFO_DIR/meminfo.txt
    cat /proc/meminfo >> $REPORT_INFO_DIR/meminfo.txt
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "=== Memory Information ===" > $REPORT_INFO_DIR/meminfo.txt
    vm_stat >> $REPORT_INFO_DIR/meminfo.txt
else
    echo "Memory information file not found."
    exit 1
fi

# Capture Latest Commit
REPO_PATH="."
cd "$REPO_PATH" || { echo "Invalid repository path"; exit 1; }
LATEST_COMMIT=$(git rev-parse HEAD)
echo "$LATEST_COMMIT" > $REPORT_INFO_DIR/latest_commit.txt
echo "Latest commit hash saved to $REPORT_INFO_DIR/latest_commit.txt: $LATEST_COMMIT"

# Capture human-readable timestamp
date +"%A, %B %d, %Y %H:%M:%S %Z" > "$REPORT_INFO_DIR/timestamp.txt"
echo "Timestamp saved to $REPORT_INFO_DIR/timestamp.txt"

# Copy all files from REPORT_INFO_DIR to benchmark_results directory
BENCHMARK_RESULTS_DIR="./benchmark_results"
mkdir -p "$BENCHMARK_RESULTS_DIR"

# Fix ownership and permissions if directory exists
if [ -d "$BENCHMARK_RESULTS_DIR" ]; then
    sudo chown -R $(whoami):$(whoami) "$BENCHMARK_RESULTS_DIR"
    chmod -R 755 "$BENCHMARK_RESULTS_DIR"
fi

echo "Copying machine info files to benchmark_results directory..."
if [ -d "$REPORT_INFO_DIR" ]; then
    cp "$REPORT_INFO_DIR"/* "$BENCHMARK_RESULTS_DIR/"
    echo "Machine info files copied to $BENCHMARK_RESULTS_DIR"
else
    echo "Warning: $REPORT_INFO_DIR directory not found"
fi