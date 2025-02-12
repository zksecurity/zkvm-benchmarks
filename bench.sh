#!/bin/bash

echo "Running benchmark..."

whoami

just bench-stone-fib-time

echo "Finished running bench-stone-fib-time"

echo "Results" > results.txt
