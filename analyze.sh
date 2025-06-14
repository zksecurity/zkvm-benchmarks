#!/bin/bash

set -e

VENV_PATH=".venv"
echo "Creating virtual environment in $VENV_PATH..."
python3 -m venv "$VENV_PATH"
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"
echo "Upgrading pip..."
pip install --upgrade pip
echo "Installing dependencies..."
pip install pandas
pip install matplotlib
pip install numpy
pip install jinja2 tabulate
echo "Installing pandoc..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt -y install pandoc
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install pandoc
else
    echo "Please install pandoc manually for your OS."
    exit 1
fi

echo "Creating report..."
rm -rf report
mkdir -p report

python analyze_md.py
cp -r plots report/
pandoc index.md -o report/index.html --standalone --metadata title="zkVM Benchmark Report"