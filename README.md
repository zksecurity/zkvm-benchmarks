# zkVM Benchmarks

## Installation
### Install Jolt
```bash
rustup target add riscv32i-unknown-none-elf
```

### Install Risc Zero
```bash
cargo install cargo-binstall
cargo binstall cargo-risczero
cargo risczero install
```

### Install SP1
```bash
curl -L https://sp1.succinct.xyz | bash
```

Follow the instructions outputted by this command then run:
```bash
sp1up
```

### Install stone-cli
```bash
git clone git@github.com:zksecurity/stone-cli.git
cd stone-cli
cargo install --path .
```

## Running
To run all benchmarks run:
```bash
make bench-all
```

The benchmark results should be outputted in CSV form in `benchmark_outputs`.

To run an individual benchmark run `make bench-jolt`, `make bench-risczero`, `make bench-sp1` or `make bench-stone`.


## Acknowledgement

These benchmarks are adapted from the following repository by a16z:  
[zkvm-benchmarks by a16z](https://github.com/a16z/zkvm-benchmarks)
