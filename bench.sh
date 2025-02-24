#!/bin/bash

echo "Running benchmark..."

whoami

source $HOME/.cargo/env
export PATH="$HOME/.cargo/env:$PATH"
export PATH="$HOME/.risc0/bin:$PATH"
export PATH="$HOME/.sp1/bin:$PATH"

VENV_PATH="$HOME/python-venv"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"

# Check Setup
rustc --version
cargo --version
stone-cli --version
python3.10 --version
cairo-run --version

# Capture Machine Info
MACHINE_INFO_DIR="./machine_info"
mkdir -p $MACHINE_INFO_DIR

echo "Capturing CPU information..."
echo "=== CPU Information ===" > $MACHINE_INFO_DIR/cpuinfo.txt
lscpu | grep -E "^(Model name|Architecture|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket|Socket\(s\)|CPU MHz|L3 cache)" >> $MACHINE_INFO_DIR/cpuinfo.txt

echo "Capturing OS version information..."
if [ -f /etc/os-release ]; then
    PRETTY_NAME=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
    echo "OS Version Information: $PRETTY_NAME" > $MACHINE_INFO_DIR/os_version.txt
else
    OS_INFO=$(uname -a)
    echo "OS Version Information: $OS_INFO" > $MACHINE_INFO_DIR/os_version.txt
fi

echo "Capturing memory information..."
echo "=== Memory Information ===" > $MACHINE_INFO_DIR/meminfo.txt
grep -E "^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree)" /proc/meminfo >> $MACHINE_INFO_DIR/meminfo.txt

echo "System information captured in $MACHINE_INFO_DIR:"

# Benchmark
echo "Start benchmarking"
just
echo "Finished benchmarking"
