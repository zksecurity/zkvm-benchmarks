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

make build-utils

echo "Start benchmarking Stone"
make build-stone
make bench-stone-fib-time
make bench-stone-keccak-time
make bench-stone-keccak-builtin-time
echo "Finished benchmarking Stone"

echo "Results" > results.txt
