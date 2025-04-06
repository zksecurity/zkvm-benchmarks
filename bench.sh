#!/bin/bash

echo "Running benchmark..."

whoami

source $HOME/.cargo/env
source $HOME/.bashrc
export PATH="$HOME/.cargo/env:$PATH"
export PATH="$HOME/.risc0/bin:$PATH"
export PATH="$HOME/.sp1/bin:$PATH"
export PATH="/usr/local/bin:$HOME/.asdf/shims:$PATH"

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
scarb --version

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

# Capture Latest Commit
REPO_PATH=${1:-"."}
cd "$REPO_PATH" || { echo "Invalid repository path"; exit 1; }
LATEST_COMMIT=$(git rev-parse HEAD)
echo "$LATEST_COMMIT" > $REPORT_INFO_DIR/latest_commit.txt
echo "Latest commit hash saved to $REPORT_INFO_DIR/latest_commit.txt: $LATEST_COMMIT"

# Benchmark
echo "Start benchmarking"
just
echo "Finished benchmarking"
