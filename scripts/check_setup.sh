#!/bin/bash

set -e

echo "Checking setup..."

whoami

OS_TYPE=$(uname)

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
if [[ "$OS_TYPE" == "Linux" ]]; then
    python3.10 --version
else
    python3 --version
fi
cairo-run --version