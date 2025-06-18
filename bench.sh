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
if command -v python3.10 &>/dev/null; then
    python3.10 --version
else
    python3 --version
fi
cairo-run --version

# Capture Machine Info
REPORT_INFO_DIR="./report_info"
mkdir -p $REPORT_INFO_DIR

OS_TYPE=$(uname)

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
date +"%A, %B %d, %Y %H:%M:%S %Z" > "$REPORT_INFO_DIR/time_stamp.txt"
echo "Timestamp saved to $REPORT_INFO_DIR/time_stamp.txt"

# Compile the memuse program
if command -v gcc &>/dev/null; then
    gcc memuse.c -o memuse
else
    echo "gcc not found"
    exit 1
fi

# Accept a single mode argument: local, remote, or dev
MODE="${1:-local}"

echo "Start benchmarking"
if [ "$MODE" = "local" ]; then
    FIB_ARG="4096 8192 16384 32768 65536 131072"
    SHA_ARG="256 512 1024 2048 4096 8192"
    SHA_CHAIN_ARG="8 16 32 64 128 256 512 1024 2048 4096"
    MATMUL_ARG="4 8 16 32 64"
    EC_ARG="16 32 64 128 256 512 1024 2048"
    just bench-local "$FIB_ARG" "$SHA_ARG" "$SHA_CHAIN_ARG" "$MATMUL_ARG" "$EC_ARG"
elif [ "$MODE" = "remote" ]; then
    FIB_ARG="4096 8192 16384 32768 65536 131072 262144 524288"
    SHA_ARG="256 512 1024 2048 4096 8192 16384 32768"
    SHA_CHAIN_ARG="8 16 32 64 128 256 512 1024 2048 4096 8192"
    MATMUL_ARG="4 8 16 32 64"
    EC_ARG="16 32 64 128 256 512 1024 2048"
    just bench-all "$FIB_ARG" "$SHA_ARG" "$SHA_CHAIN_ARG" "$MATMUL_ARG" "$EC_ARG"
elif [ "$MODE" = "dev" ]; then
    FIB_ARG="4096 8192 16384"
    SHA_ARG="256 512 1024"
    SHA_CHAIN_ARG="8 16 32"
    MATMUL_ARG="4 8 16"
    EC_ARG="16 32 64"
    just bench-all "$FIB_ARG" "$SHA_ARG" "$SHA_CHAIN_ARG" "$MATMUL_ARG" "$EC_ARG"
else
    echo "Unknown mode: $MODE"
    echo "Usage: $0 [local|remote|dev]"
    exit 1
fi
echo "Finished benchmarking"