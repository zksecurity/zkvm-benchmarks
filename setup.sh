#!/bin/bash

echo "Setting up benchmark..."

whoami

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
export PATH="$HOME/.cargo/env:$PATH"

# Install Python3.10
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install -y python3.10 python3.10-venv python3.10-distutils

# Install other dependencies
sudo apt update -y
sudo apt install -y heaptrack
sudo apt install -y build-essential
sudo apt install -y pkg-config
sudo apt install -y libssl-dev
sudo apt install -y libgmp-dev
sudo apt install -y clang
sudo apt install -y age
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
VENV_PATH="$HOME/python-venv"
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

# Install asdf

# Define the installation directory and the desired asdf version tag
ASDF_DIR="$HOME/.asdf"
ASDF_VERSION="v0.13.1"  # Change this version if you want a different release

# Check if asdf is already installed
if [ -d "$ASDF_DIR" ]; then
    echo "asdf is already installed at $ASDF_DIR"
    exit 0
fi

# Update package lists and install dependencies
echo "Updating package lists and installing dependencies..."
sudo apt update
sudo apt install -y curl git

# Clone the asdf repository
echo "Cloning asdf from GitHub..."
git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch "$ASDF_VERSION"

# Add asdf initialization to ~/.bashrc if not already present
BASHRC="$HOME/.bashrc"
if ! grep -q "asdf.sh" "$BASHRC"; then
    echo "Adding asdf initialization to $BASHRC..."
    {
        echo ""
        echo "# asdf initialization"
        echo ". $ASDF_DIR/asdf.sh"
        echo ". $ASDF_DIR/completions/asdf.bash"
    } >> "$BASHRC"
fi

# Source the updated .bashrc to load asdf immediately
echo "Sourcing $BASHRC..."
source "$BASHRC"

echo "asdf installation completed successfully!"

# Install scarb
asdf install scarb 2.10.1
asdf global scarb 2.10.1

# Check Setup
rustc --version
cargo --version
stone-cli --version
python3.10 --version
cairo-run --version
asdf --version
