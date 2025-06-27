#!/bin/bash

set -e

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
    brew install python pkg-config openssl gmp clang just unzip
else
    echo "Unsupported OS: $OS_TYPE"
    exit 1
fi

# Install Rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
export PATH="$HOME/.cargo/bin:$PATH"
