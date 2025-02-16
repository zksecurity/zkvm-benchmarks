#!/bin/bash

echo "Running benchmark..."

whoami

source $HOME/.cargo/env
export PATH="$HOME/.cargo/env:$PATH"

VENV_PATH="$HOME/python-venv"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"

# Check Setup
rustc --version || echo "Rust installation failed"
cargo --version || echo "Cargo installation failed"
stone-cli --version || echo "stone-cli installation failed"
python3.10 --version || echo "Python installation failed"
cairo-run --version || echo "Cairo installation failed"

# Capture Machine Info
MACHINE_INFO_DIR="./machine_info"
mkdir -p $MACHINE_INFO_DIR

echo "Capturing CPU information..."
echo "=== CPU Information ===" > $MACHINE_INFO_DIR/cpuinfo.txt
grep -E "^(model name|cpu MHz|cache size|siblings|cpu cores)" /proc/cpuinfo | sort -u >> $MACHINE_INFO_DIR/cpuinfo.txt

echo "Capturing memory information..."
echo "=== Memory Information ===" > $MACHINE_INFO_DIR/meminfo.txt
grep -E "^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree)" /proc/meminfo >> $MACHINE_INFO_DIR/meminfo.txt

echo "Capturing OS version information..."
if [ -f /etc/os-release ]; then
    echo "=== OS Version Information ===" > $MACHINE_INFO_DIR/os_version.txt
    cat /etc/os-release >> $MACHINE_INFO_DIR/os_version.txt
else
    uname -a > $MACHINE_INFO_DIR/os_version.txt
fi

echo "Capturing hardware details..."
lscpu | grep -E "^(Model name|Architecture|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket|Socket\(s\)|CPU MHz|L3 cache)" > $MACHINE_INFO_DIR/lscpu.txt

echo "System information captured in $MACHINE_INFO_DIR:"

# Benchmark
echo "Start benchmarking"
just
echo "Finished benchmarking"
