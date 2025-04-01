# zkVM Benchmarks

## Installation

Run the setup script to install all dependencies:
```bash
./setup.sh
```

## Running Benchmarks

To run all benchmarks, use:
```bash
just bench-all
```

The benchmark results will be saved in CSV format in the `benchmark_outputs` directory.

To run an individual benchmark, use `just bench-jolt`, `just bench-risczero`, `just bench-sp1`, `just bench-stone` or `just bench-stwo`.

## Acknowledgement

These benchmarks are adapted from the following repository by a16z:  
[zkvm-benchmarks by a16z](https://github.com/a16z/zkvm-benchmarks)
