#!/bin/bash

VENV_PATH="$HOME/analyze-venv"
echo "Creating virtual environment in $VENV_PATH..."
python3 -m venv "$VENV_PATH"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"
echo "Upgrading pip..."
pip install --upgrade pip
echo "Installing dependencies..."
pip install marimo
pip install pandas
pip install matplotlib

# check setup
marimo --version || echo "Marimo installation failed"

echo "Analyzing benchmark results..."

# Run marimo notebook
# marimo run analyze.py