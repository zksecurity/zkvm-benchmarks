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
pip install marimo
pip install pandas
pip install matplotlib
pip install ipython
pip install numpy
pip install jinja2 tabulate
sudo apt -y install pandoc
marimo --version

# run marimo notebook
echo "Creating report..."
rm -rf report
mkdir -p report
# marimo export html analyze.py -o report/index.html --no-include-code

python analyze_md.py
cp -r plots report/
pandoc index.md -o report/index.html --standalone --metadata title="zkVM Benchmark Report"