#!/bin/bash

echo "Running benchmark..."

whoami

just build-utils
just build-stone
just bench-stone-fib-time!
just bench-stone-keccak-time!

echo "Finished running bench-stone-fib-time"

echo "Results" > results.txt
