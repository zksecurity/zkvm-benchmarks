#!/bin/bash

echo "Setting up benchmark..."

whoami

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/bin
export PATH="$HOME/.cargo/bin:$PATH"
rustup install 1.81.0
rustup install nightly-2025-01-02

# Install Python3.10
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install -y python3.10 python3.10-venv python3.10-distutils

# Install other dependencies
sudo apt update -y
sudo apt install -y build-essential
sudo apt install -y pkg-config
sudo apt install -y libssl-dev
sudo apt install -y libgmp-dev
sudo apt install -y clang
sudo apt install -y just
sudo apt install -y unzip

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
echo "Creating virtual environment in $VENV_PATH..."
python3.10 -m venv "$VENV_PATH"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"
echo "Upgrading pip..."
pip install --upgrade pip
echo "Installing cairo-lang..."
pip install cairo-lang

# Install stone-cli
cargo install --git https://github.com/zksecurity/stone-cli.git

# Install scarb
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh -s -- -v nightly-2025-02-26
export PATH="$HOME/.local/bin:$PATH"

# Check Setup
rustc --version
cargo --version
stone-cli --version
python3.10 --version
cairo-run --version
scarb --version