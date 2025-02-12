#!/bin/bash

echo "Setting up benchmark..."

whoami

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
export PATH="$HOME/.cargo/env:$PATH"

rustc --version || echo "Rust installation failed"
cargo --version || echo "Cargo installation failed"

# Install other dependencies
sudo apt update -y
sudo apt install -y heaptrack
sudo apt install -y build-essential
sudo apt install -y pkg-config
sudo apt install -y libssl-dev
sudo apt install -y python3-pip
sudo apt install -y python3-venv
sudo apt install -y libgmp-dev
sudo apt install -y clang
sudo apt install -y age
sudo apt install -y just

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

# Install stone-cli
cargo install --git https://github.com/zksecurity/stone-cli.git --branch dynamic-layout
stone-cli --version || echo "stone-cli installation failed"

# Install cairo
VENV_PATH="$HOME/python-venv"
echo "Creating virtual environment in $VENV_PATH..."
python3 -m venv "$VENV_PATH"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"
echo "Upgrading pip..."
pip install --upgrade pip
echo "Installing cairo-lang..."
pip install cairo-lang