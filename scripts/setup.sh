#!/bin/bash

set -e

echo "Setting up benchmark..."

whoami

OS_TYPE=$(uname)

# OS-specific dependencies
if [[ "$OS_TYPE" == "Linux" ]]; then
    # Install Python3.10 and system dependencies
    sudo apt update -y
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update -y
    sudo apt install -y python3.10 python3.10-venv python3.10-distutils
    sudo apt install -y build-essential pkg-config libssl-dev libgmp-dev clang just unzip
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    # Install Homebrew dependencies
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Please install Homebrew first: https://brew.sh/"
        exit 1
    fi
    brew install python@3.10 pkg-config openssl gmp just unzip
else
    echo "Unsupported OS: $OS_TYPE"
    exit 1
fi

# Common steps for all OSes

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"
rustup install 1.81.0
rustup install 1.86.0
rustup install nightly-2025-01-02
rustup install stable

# Install Jolt
rustup target add riscv32i-unknown-none-elf

# Install Risc Zero
curl -L https://risczero.com/install | bash
export PATH="$HOME/.risc0/bin:$PATH"
rzup install

# Install SP1
curl -L https://sp1.succinct.xyz | bash
export PATH="$HOME/.sp1/bin:$PATH"
sp1up

# Install cairo
VENV_PATH="$HOME/bench-venv"
python3.10 -m venv "$VENV_PATH"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"
echo "Upgrading pip..."
pip install --upgrade pip
echo "Installing cairo-lang..."
pip install cairo-lang

# Install stone-cli
cargo +1.86.0 install --git https://github.com/zksecurity/stone-cli.git

# Check Setup
rustc --version
cargo --version
stone-cli --version
python3.10 --version
cairo-run --version