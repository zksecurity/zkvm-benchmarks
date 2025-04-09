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
# sudo apt install -y heaptrack
sudo apt install -y build-essential
sudo apt install -y pkg-config
sudo apt install -y libssl-dev
sudo apt install -y libgmp-dev
sudo apt install -y clang
# sudo apt install -y age
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

# # Install asdf
# INSTALL_DIR="/usr/local/bin"
# ASDF_BINARY="$INSTALL_DIR/asdf"
# ASDF_VERSION="v0.16.4"

# ASDF_URL="https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf-${ASDF_VERSION}-linux-amd64.tar.gz"
# echo "Downloading asdf from: $ASDF_URL"

# TEMP_DIR=$(mktemp -d)

# curl -L "$ASDF_URL" -o "$TEMP_DIR/asdf.tar.gz"

# tar -xzf "$TEMP_DIR/asdf.tar.gz" -C "$TEMP_DIR"

# echo "Installing asdf to $INSTALL_DIR..."
# sudo mv "$TEMP_DIR/asdf" "$ASDF_BINARY"
# sudo chmod +x "$ASDF_BINARY"

# rm -rf "$TEMP_DIR"

# echo "Verifying asdf installation..."
# if type -a asdf | grep -q "$INSTALL_DIR"; then
#     echo "asdf installed successfully at $INSTALL_DIR."
#     asdf --version
# else
#     echo "asdf installation failed. Ensure $INSTALL_DIR is in your PATH."
#     exit 1
# fi
# export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Install scarb
# asdf plugin add scarb
# asdf install scarb nightly-2025-02-26
# # asdf global scarb latest:nightly
# echo "scarb nightly-2025-02-26" >> $HOME/.tool-versions
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh -s -- -v nightly-2025-02-26
export PATH="$HOME/.local/bin:$PATH"

# Check Setup
rustc --version
cargo --version
stone-cli --version
python3.10 --version
cairo-run --version
scarb --version