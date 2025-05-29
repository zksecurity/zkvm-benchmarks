#!/bin/bash

echo "Running benchmark..."

whoami

source $HOME/.cargo/env
source $HOME/.bashrc
export PATH="$HOME/.cargo/env:$PATH"
export PATH="$HOME/.risc0/bin:$PATH"
export PATH="$HOME/.sp1/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

VENV_PATH="$HOME/bench-venv"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"
rustup show

# Check Setup
rustc --version
cargo --version
stone-cli --version
python3.10 --version
cairo-run --version

# Capture Machine Info
REPORT_INFO_DIR="./report_info"
mkdir -p $REPORT_INFO_DIR

echo "Capturing CPU information..."
echo "=== CPU Information ===" > $REPORT_INFO_DIR/cpuinfo.txt
lscpu >> $REPORT_INFO_DIR/cpuinfo.txt

echo "Capturing OS version information..."
if [ -f /etc/os-release ]; then
    echo "=== OS Information ===" > $REPORT_INFO_DIR/os_version.txt
    cat /etc/os-release >> $REPORT_INFO_DIR/os_version.txt
else
    echo "OS information file not found." > $REPORT_INFO_DIR/os_version.txt
fi

echo "Capturing memory information..."
if [ -f /proc/meminfo ]; then
    echo "=== Memory Information ===" > $REPORT_INFO_DIR/meminfo.txt
    cat /proc/meminfo >> $REPORT_INFO_DIR/meminfo.txt
else
    echo "Memory information file not found." >> $REPORT_INFO_DIR/meminfo.txt
fi

# Repo path comes first, default to current dir
REPO_PATH="${1:-.}"
shift # Drop the first argument, so $1 $2 $3 $4 $5 are now the benchmarks

# Capture Latest Commit
cd "$REPO_PATH" || { echo "Invalid repository path"; exit 1; }
LATEST_COMMIT=$(git rev-parse HEAD)
echo "$LATEST_COMMIT" > $REPORT_INFO_DIR/latest_commit.txt
echo "Latest commit hash saved to $REPORT_INFO_DIR/latest_commit.txt: $LATEST_COMMIT"

# Capture human-readable timestamp
date +"%A, %B %d, %Y %H:%M:%S %Z" > "$REPORT_INFO_DIR/time_stamp.txt"
echo "Timestamp saved to $REPORT_INFO_DIR/time_stamp.txt"

# Compile the memuse program
gcc memuse.c -o memuse

# Benchmark
echo "Start benchmarking"
just bench-all "$1" "$2" "$3" "$4" "$5"
echo "Finished benchmarking"