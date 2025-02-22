#!/bin/bash

echo "Analyzing benchmark results..."

VENV_PATH="$HOME/python-venv"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"

# check setup
marimo --version || echo "Marimo installation failed"