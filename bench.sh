#!/bin/bash

echo "Running benchmark..."

whoami

make build-utils
make build-stone
make bench-stone-fib-time
make bench-stone-keccak-time

echo "Finished running bench-stone-fib-time"

echo "Results" > results.txt
