# zkVM Benchmarks

This repository provides scripts and tools to benchmark various zkVM and proof systems on **Linux** and **macOS**.

## Installation

Run the setup script to install all dependencies:
```bash
./scripts/setup.sh
```

## Running Benchmarks

To run all benchmarks, use:
```bash
just bench-local
```

The benchmark results will be saved in JSON format in the `benchmark_results` directory.

## Generating a Report

To generate a local HTML report from the benchmark results, run:
```bash
./scripts/analyze.sh
```

The report will be generated at:  `./report/index.html`.