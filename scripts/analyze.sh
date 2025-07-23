#!/bin/bash

set -e

OS_TYPE=$(uname)

VENV_PATH="$HOME/analyze-venv"
echo "Creating virtual environment in $VENV_PATH..."
python3 -m venv "$VENV_PATH"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"
echo "Upgrading pip..."
pip install --upgrade pip
echo "Installing dependencies..."
pip install pandas matplotlib numpy jinja2 tabulate
echo "Installing pandoc..."
if [[ "$OS_TYPE" == "Linux" ]]; then
    sudo apt -y install pandoc
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    brew install pandoc
else
    echo "Please install pandoc manually for your OS."
    exit 1
fi

echo "Creating report..."
rm -rf report
mkdir -p report

# Check if 'local' argument is provided
if [[ "$1" == "local" ]]; then
    echo "Running local analysis..."
    python ./scripts/analyze_local.py
else
    echo "Running standard analysis..."
    python ./scripts/analyze.py
fi

cp -r plots report/
pandoc index.md -o report/index.html --standalone --metadata title="zkVM Benchmark Report"