#!/bin/bash

echo "Setting up benchmark..."

whoami

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env" 

# # Install other dependencies
# sudo apt update -y
# sudo apt install -y heaptrack
# sudo apt install -y build-essential
# sudo apt install -y pkg-config
# sudo apt install -y libssl-dev
# sudo apt install -y python3-pip
# sudo apt install -y python3-venv
# sudo apt install -y libgmp-dev
# sudo apt install -y clang
# sudo apt install -y age
# sudo apt install -y just

# # Install Jolt
# rustup target add riscv32i-unknown-none-elf

# Install Risc Zero
curl -L https://risczero.com/install | bash
export PATH="$HOME/.risc0/bin:$PATH"
echo "PATH after sourcing .bashrc: $PATH"
rzup install

# Install SP1
curl -L https://sp1.succinct.xyz | bash
. "$HOME/.bashrc"
sp1up

# # Install stone-cli
# cargo install --git https://github.com/zksecurity/stone-cli.git --branch dynamic-layout

# # Install cairo
# pip install cairo-lang

# Install SHARP certificate for dynamic layout
REPO_URL="https://x-access-token:${PERSONAL_ACCESS_TOKEN}@github.com/zksecurity/sharp-cert.git"
git clone "${REPO_URL}" ~/sharp-cert
cd ~/sharp-cert
age --decrypt -o user.key user.key.age
