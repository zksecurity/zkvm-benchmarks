# zkVM Benchmarks

This repository provides scripts and tools to benchmark various zkVM and proof systems on **Linux** and **macOS**.

## Installation

Run the setup script to install all dependencies:
```bash
./setup.sh
```

## Running Benchmarks

To run all benchmarks, use:
```bash
./bench local
```

The benchmark results will be saved in CSV format in the `benchmark_outputs` directory.

## Generating a Report

To generate a local HTML report from the benchmark results, run:
```bash
./analyze.sh
```

The report will be generated at:  `./report/index.html`.
