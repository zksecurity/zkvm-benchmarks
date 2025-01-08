FIB_ARGS = 100 1000 10000 50000
SHA_ARGS = 32 256 512 1024 2048
BINARY_SEARCH_ARGS = 4 8 16 32 64


bench-all:
	make build-utils
	make bench-jolt
	make bench-sp1
	make bench-risczero
	make bench-stone

build-utils:
	cd utils && cargo build


#####
# jolt
#####

bench-jolt:
	cd jolt && cargo build --release
	make bench-jolt-fib
	make bench-jolt-sha2
	make bench-jolt-sha3
	make bench-jolt-mat-mul
	make bench-jolt-binary-search

bench-jolt-fib:
	make bench-jolt-fib-time
	make bench-jolt-fib-mem

bench-jolt-fib-time:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(FIB_ARGS)) -- --program fib
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(FIB_ARGS)) -- --program fib
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(FIB_ARGS)) -- --program fib
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(FIB_ARGS)) -- --program fib

bench-jolt-fib-mem:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(FIB_ARGS)) --bench-mem -- --program fib
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(FIB_ARGS)) --bench-mem -- --program fib
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(FIB_ARGS)) --bench-mem -- --program fib
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-fib --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(FIB_ARGS)) --bench-mem -- --program fib

bench-jolt-sha2:
	make bench-jolt-sha2-time
	make bench-jolt-sha2-mem

bench-jolt-sha2-time:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(SHA_ARGS)) -- --program sha2
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(SHA_ARGS)) -- --program sha2
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(SHA_ARGS)) -- --program sha2
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(SHA_ARGS)) -- --program sha2
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(SHA_ARGS)) -- --program sha2

bench-jolt-sha2-mem:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(SHA_ARGS)) --bench-mem -- --program sha2
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(SHA_ARGS)) --bench-mem -- --program sha2
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(SHA_ARGS)) --bench-mem -- --program sha2
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(SHA_ARGS)) --bench-mem -- --program sha2
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2 --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(SHA_ARGS)) --bench-mem -- --program sha2

bench-jolt-sha3:
	make bench-jolt-sha3-time
	make bench-jolt-sha3-mem

bench-jolt-sha3-time:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(SHA_ARGS)) -- --program sha3
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(SHA_ARGS)) -- --program sha3
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(SHA_ARGS)) -- --program sha3
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(SHA_ARGS)) -- --program sha3
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(SHA_ARGS)) -- --program sha3

bench-jolt-sha3-mem:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(SHA_ARGS)) --bench-mem -- --program sha3
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(SHA_ARGS)) --bench-mem -- --program sha3
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(SHA_ARGS)) --bench-mem -- --program sha3
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(SHA_ARGS)) --bench-mem -- --program sha3
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3 --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(SHA_ARGS)) --bench-mem -- --program sha3

bench-jolt-mat-mul:
	make bench-jolt-mat-mul-time
	make bench-jolt-mat-mul-mem

bench-jolt-mat-mul-time:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg 100 -- --program mat-mul
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg 500 -- --program mat-mul
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg 1000 -- --program mat-mul
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg 10000 -- --program mat-mul

bench-jolt-mat-mul-mem:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg 100 --bench-mem -- --program mat-mul 
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg 500 --bench-mem -- --program mat-mul 
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg 1000 --bench-mem -- --program mat-mul 
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg 10000 --bench-mem -- --program mat-mul 

bench-jolt-binary-search:
	make bench-jolt-binary-search-time
	make bench-jolt-binary-search-mem

bench-jolt-binary-search-time:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(BINARY_SEARCH_ARGS)) -- --program binary-search
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(BINARY_SEARCH_ARGS)) -- --program binary-search
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(BINARY_SEARCH_ARGS)) -- --program binary-search
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(BINARY_SEARCH_ARGS)) -- --program binary-search
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(BINARY_SEARCH_ARGS)) -- --program binary-search

bench-jolt-binary-search-mem:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-binary-search --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search


#####
# sp1
#####

build-sp1:
	cd sp1/fibonacci && cargo prove build
	cd sp1/sha2-chain && cargo prove build
	cd sp1/sha3-chain && cargo prove build
	cd sp1/sha2 && cargo prove build
	cd sp1/sha3 && cargo prove build
	cd sp1/bigmem && cargo prove build
	cd sp1/binary-search && cargo prove build
	cd sp1/mat-mul && cargo prove build
	cd sp1 && cargo build --release

bench-sp1:
	make build-sp1
	# make bench-sp1-fib
	make bench-sp1-sha2
	make bench-sp1-sha3
	make bench-sp1-mat-mul
	make bench-sp1-binary-search

bench-sp1-fib:
	make bench-sp1-fib-time
	make bench-sp1-fib-mem

bench-sp1-sha2:
	make bench-sp1-sha2-time
	make bench-sp1-sha2-mem

bench-sp1-sha3:
	make bench-sp1-sha3-time
	make bench-sp1-sha3-mem

bench-sp1-mat-mul:
	make bench-sp1-mat-mul-time
	make bench-sp1-mat-mul-mem

bench-sp1-binary-search:
	make bench-sp1-binary-search-time
	make bench-sp1-binary-search-mem

bench-sp1-fib-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg $(word 1, $(FIB_ARGS)) -- --program fib
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg $(word 2, $(FIB_ARGS)) -- --program fib
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg $(word 3, $(FIB_ARGS)) -- --program fib
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg $(word 4, $(FIB_ARGS)) -- --program fib

bench-sp1-fib-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg $(word 1, $(FIB_ARGS)) --bench-mem -- --program fib 
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg $(word 2, $(FIB_ARGS)) --bench-mem -- --program fib 
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg $(word 3, $(FIB_ARGS)) --bench-mem -- --program fib 
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-fib --bin target/release/sp1-script --bench-arg $(word 4, $(FIB_ARGS)) --bench-mem -- --program fib 

bench-sp1-sha2-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_ARGS)) -- --program sha2
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_ARGS)) -- --program sha2
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_ARGS)) -- --program sha2
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_ARGS)) -- --program sha2
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_ARGS)) -- --program sha2

bench-sp1-sha2-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_ARGS)) --bench-mem -- --program sha2
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_ARGS)) --bench-mem -- --program sha2
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_ARGS)) --bench-mem -- --program sha2
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_ARGS)) --bench-mem -- --program sha2
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2 --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_ARGS)) --bench-mem -- --program sha2

bench-sp1-sha3-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_ARGS)) -- --program sha3
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_ARGS)) -- --program sha3
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_ARGS)) -- --program sha3
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_ARGS)) -- --program sha3
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_ARGS)) -- --program sha3

bench-sp1-sha3-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_ARGS)) --bench-mem -- --program sha3
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_ARGS)) --bench-mem -- --program sha3
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_ARGS)) --bench-mem -- --program sha3
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_ARGS)) --bench-mem -- --program sha3
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3 --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_ARGS)) --bench-mem -- --program sha3

bench-sp1-mat-mul-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 100 -- --program mat-mul
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 500 -- --program mat-mul
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 1000 -- --program mat-mul
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 10000 -- --program mat-mul

bench-sp1-mat-mul-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 100 --bench-mem -- -- --program mat-mul
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 500 --bench-mem -- -- --program mat-mul
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 1000 --bench-mem -- -- --program mat-mul
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 10000 --bench-mem -- -- --program mat-mul

bench-sp1-binary-search-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 1, $(BINARY_SEARCH_ARGS)) -- --program binary-search
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 2, $(BINARY_SEARCH_ARGS)) -- --program binary-search
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 3, $(BINARY_SEARCH_ARGS)) -- --program binary-search
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 4, $(BINARY_SEARCH_ARGS)) -- --program binary-search
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 5, $(BINARY_SEARCH_ARGS)) -- --program binary-search

bench-sp1-binary-search-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 1, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search 
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 2, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search 
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 3, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search 
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 4, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search 
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-binary-search --bin target/release/sp1-script --bench-arg $(word 5, $(BINARY_SEARCH_ARGS)) --bench-mem -- --program binary-search 


#####
# risczero
#####

bench-risczero:
	make build-risczero
	bench-risczero-mat-mul

build-risczero:
	cd risczero/sha2-chain && cargo build --release
	cd risczero/fibonacci && cargo build --release
	cd risczero/sha3-chain && cargo build --release
	cd risczero/sha2 && cargo build --release
	cd risczero/sha3 && cargo build --release
	cd risczero/bigmem && cargo build --release
	cd risczero/mat-mul && cargo build --release

bench-risczero-mat-mul:
	make bench-risczero-mat-mul-time
	# make bench-risczero-mat-mul-mem

bench-risczero-mat-mul-time:
	-cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg 100 
	-cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg 500 
	-cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg 1000 
	-cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg 10000 

bench-risczero-sha2:
	make bench-risczero-sha2-time
	# make bench-risczero-sha2-mem

bench-risczero-sha2-time:
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 1, $(SHA_ARGS))
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 2, $(SHA_ARGS))
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 3, $(SHA_ARGS))
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 4, $(SHA_ARGS))
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 5, $(SHA_ARGS))

bench-risczero-sha3:
	make bench-risczero-sha3-time
	# make bench-risczero-sha3-mem

bench-risczero-sha3-time:
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 1, $(SHA_ARGS))
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 2, $(SHA_ARGS))
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 3, $(SHA_ARGS))
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 4, $(SHA_ARGS))
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 5, $(SHA_ARGS))

# bench-risczero-fib:
# 	cd risczero/fibonacci && cargo build --release
# 	make bench-risczero-fib-time
# 	make bench-risczero-fib-mem

# bench-risczero-fib-time:
# 	cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 1, $(FIB_ARGS))
# 	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 2, $(FIB_ARGS))
# 	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 3, $(FIB_ARGS))
# 	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 4, $(FIB_ARGS))

# bench-risczero-fib-mem:
# 	cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 1, $(FIB_ARGS)) --bench-mem
# 	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 2, $(FIB_ARGS)) --bench-mem
# 	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 3, $(FIB_ARGS)) --bench-mem
# 	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 4, $(FIB_ARGS)) --bench-mem

bench-risczero-binary-search:
	make bench-risczero-binary-search-time
	make bench-risczero-binary-search-mem

bench-risczero-binary-search-time:
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 1, $(BINARY_SEARCH_ARGS))
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 2, $(BINARY_SEARCH_ARGS))
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 3, $(BINARY_SEARCH_ARGS))
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 4, $(BINARY_SEARCH_ARGS))
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 5, $(BINARY_SEARCH_ARGS))

bench-risczero-binary-search-mem:
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 1, $(BINARY_SEARCH_ARGS)) --bench-mem
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 2, $(BINARY_SEARCH_ARGS)) --bench-mem
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 3, $(BINARY_SEARCH_ARGS)) --bench-mem
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 4, $(BINARY_SEARCH_ARGS)) --bench-mem
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 5, $(BINARY_SEARCH_ARGS)) --bench-mem


#####
# stone
#####

bench-stone:
	make build-stone
	make bench-stone-time
	make bench-stone-mem

bench-stone-time:
	make bench-stone-fib-time
	make bench-stone-keccak-time
	make bench-stone-keccak-builtin-time
	make bench-stone-keccak-builtin-chain-time
	make bench-stone-sha256-time
	make bench-stone-sha256-chain-time
	make bench-stone-mat-time
	make bench-stone-binary-search-time

bench-stone-mem:
	make bench-stone-fib-mem
	make bench-stone-keccak-mem
	make bench-stone-keccak-builtin-mem
	make bench-stone-keccak-builtin-chain-mem
	make bench-stone-sha256-mem
	make bench-stone-sha256-chain-mem
	make bench-stone-mat-mem
	make bench-stone-binary-search-mem

build-stone:
	cd stone/fibonacci && cargo build --release
	cd stone/keccak && cargo build --release
	cd stone/keccak-builtin && cargo build --release
	cd stone/keccak-builtin-chain && cargo build --release
	cd stone/sha256 && cargo build --release
	cd stone/sha256-chain && cargo build --release
	cd stone/mat-mul && cargo build --release

bench-stone-fib-time:
	# 100, 1000, 10000, 50000
	-cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $(word 1, $(FIB_ARGS))
	-cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $(word 2, $(FIB_ARGS))
	-cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $(word 3, $(FIB_ARGS))
	-cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $(word 4, $(FIB_ARGS))

bench-stone-fib-mem:
	-cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $(word 1, $(FIB_ARGS)) --bench-mem
	-cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $(word 2, $(FIB_ARGS)) --bench-mem
	-cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $(word 3, $(FIB_ARGS)) --bench-mem
	-cd stone/fibonacci && ../../utils/target/debug/utils --bench-name stone-fib --bin target/release/stone --bench-arg $(word 4, $(FIB_ARGS)) --bench-mem

bench-stone-mat-time:
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 100
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 500
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 1000
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 10000

bench-stone-mat-memory:
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 100 --bench-mem
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 500 --bench-mem
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 1000 --bench-mem
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 10000 --bench-mem

bench-stone-keccak-time:
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 1, $(SHA_ARGS))
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 2, $(SHA_ARGS))
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 3, $(SHA_ARGS))
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 4, $(SHA_ARGS))
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 5, $(SHA_ARGS))

bench-stone-keccak-mem:
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 1, $(SHA_ARGS)) --bench-mem
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 2, $(SHA_ARGS)) --bench-mem
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 3, $(SHA_ARGS)) --bench-mem
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 4, $(SHA_ARGS)) --bench-mem
	-cd stone/keccak && ../../utils/target/debug/utils --bench-name stone-keccak --bin target/release/stone --bench-arg $(word 5, $(SHA_ARGS)) --bench-mem

bench-stone-keccak-builtin-time:
	# representing bytes 200, 400, 1000, 2000
	# as each iteration of the keccak builtin processes 200 bytes
	# let inputs = [1, 2, 5, 10];
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 1
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 2
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 5
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 10

bench-stone-keccak-builtin-mem:
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 1 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 2 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 5 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 10 --bench-mem

bench-stone-keccak-builtin-chain-time:
	# other programs use:
    # 32 bytes * 230 = 7360 bytes
    # 32 bytes * 460 = 14720 bytes
    # 32 bytes * 920 = 29440 bytes
    # 32 bytes * 1840 = 58880 bytes
    # 32 bytes * 3680 = 117760 bytes

    # to adapt to the 200 bytes per iteration of the keccak builtin,
    # the number of equivalent iterations is:
    # 7360 / 200 = 36.8
    # 14720 / 200 = 73.6
    # 29440 / 200 = 147.2
    # 58880 / 200 = 294.4
    # 117760 / 200 = 588.8
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 37
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 74
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 148
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 295
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 589

bench-stone-keccak-builtin-chain-mem:
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 37 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 74 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 148 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 295 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin --bin target/release/stone --bench-arg 589 --bench-mem

bench-stone-sha256-time:
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 1, $(SHA_ARGS))
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 2, $(SHA_ARGS))
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 3, $(SHA_ARGS))
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 4, $(SHA_ARGS))
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 5, $(SHA_ARGS))

bench-stone-sha256-mem:
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 1, $(SHA_ARGS)) --bench-mem
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 2, $(SHA_ARGS)) --bench-mem
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 3, $(SHA_ARGS)) --bench-mem
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 4, $(SHA_ARGS)) --bench-mem
	-cd stone/sha256 && ../../utils/target/debug/utils --bench-name stone-sha256 --bin target/release/sha256 --bench-arg $(word 5, $(SHA_ARGS)) --bench-mem

bench-stone-sha256-chain-time:
	# can't run this on my machine, it crashes due to out of memory
	-cd stone/sha256-chain && ../../utils/target/debug/utils --bench-name stone-sha256-chain --bin target/release/sha256-chain --bench-arg 230

bench-stone-sha256-chain-mem:
	-cd stone/sha256-chain && ../../utils/target/debug/utils --bench-name stone-sha256-chain --bin target/release/sha256-chain --bench-arg 230 --bench-mem

bench-stone-binary-search-time:
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 1, $(BINARY_SEARCH_ARGS))
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 2, $(BINARY_SEARCH_ARGS))
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 3, $(BINARY_SEARCH_ARGS))
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 4, $(BINARY_SEARCH_ARGS))
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 5, $(BINARY_SEARCH_ARGS))

bench-stone-binary-search-mem:
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 1, $(BINARY_SEARCH_ARGS)) --bench-mem
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 2, $(BINARY_SEARCH_ARGS)) --bench-mem
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 3, $(BINARY_SEARCH_ARGS)) --bench-mem
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 4, $(BINARY_SEARCH_ARGS)) --bench-mem
	-cd stone/binary-search && ../../utils/target/debug/utils --bench-name stone-binary-search --bin target/release/stone --bench-arg $(word 5, $(BINARY_SEARCH_ARGS)) --bench-mem
