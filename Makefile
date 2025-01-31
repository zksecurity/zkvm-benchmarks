FIB_ARGS = 100 1000 10000 50000
ECADD_ARGS = 2 5 10 20
SHA_ARGS = 32 256 512 1024 2048
BINARY_SEARCH_ARGS = 128 256 512 1024 2048
SHA_CHAIN_ARGS = 230 460 920 1840 3680
MATMUL_ARGS = 10 20 40 60 

bench-all:
	make build-utils
	make bench-jolt
	make bench-sp1
	make bench-risczero
	make bench-stone

bench-some:
	make build-utils
	make bench-jolt-binary-search-time
	make bench-sp1-binary-search-time
	make bench-risczero

build-utils:
	cd utils && cargo build


#####
# jolt
#####

bench-jolt:
	cd jolt && cargo build --release
	make bench-jolt-fib
	make bench-jolt-sha2
	make bench-jolt-sha2-chain
	make bench-jolt-sha3
	make bench-jolt-sha3-chain
	make bench-jolt-mat-mul
	make bench-jolt-binary-search
	make bench-jolt-ecadd

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

bench-jolt-ecadd:
	make bench-jolt-ecadd-time
	make bench-jolt-ecadd-mem

bench-jolt-ecadd-time:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-ecadd --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(ECADD_ARGS)) -- --program ecadd
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-ecadd --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(ECADD_ARGS)) -- --program ecadd
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-ecadd --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(ECADD_ARGS)) -- --program ecadd
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-ecadd --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(ECADD_ARGS)) -- --program ecadd

bench-jolt-ecadd-mem:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-ecadd --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(ECADD_ARGS)) --bench-mem -- --program ecadd
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-ecadd --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(ECADD_ARGS)) --bench-mem -- --program ecadd
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-ecadd --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(ECADD_ARGS)) --bench-mem -- --program ecadd
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-ecadd --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(ECADD_ARGS)) --bench-mem -- --program ecadd

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

bench-jolt-sha2-chain:
	make bench-jolt-sha2-chain-time
	make bench-jolt-sha2-chain-mem

bench-jolt-sha2-chain-time:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) -- --program sha2-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) -- --program sha2-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) -- --program sha2-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) -- --program sha2-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) -- --program sha2-chain

bench-jolt-sha2-chain-mem:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha2-chain --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain

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

bench-jolt-sha3-chain:
	make bench-jolt-sha3-chain-time
	make bench-jolt-sha3-chain-mem

bench-jolt-sha3-chain-time:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) -- --program sha3-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) -- --program sha3-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) -- --program sha3-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) -- --program sha3-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) -- --program sha3-chain

bench-jolt-sha3-chain-mem:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-sha3-chain --bin target/release/jolt-benchmarks --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain

bench-jolt-mat-mul:
	make bench-jolt-mat-mul-time
	make bench-jolt-mat-mul-mem

bench-jolt-mat-mul-time:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(MATMUL_ARGS)) -- --program mat-mul
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(MATMUL_ARGS)) -- --program mat-mul
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(MATMUL_ARGS)) -- --program mat-mul
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(MATMUL_ARGS)) -- --program mat-mul

bench-jolt-mat-mul-mem:
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg $(word 1, $(MATMUL_ARGS)) --bench-mem -- --program mat-mul 
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg $(word 2, $(MATMUL_ARGS)) --bench-mem -- --program mat-mul 
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg $(word 3, $(MATMUL_ARGS)) --bench-mem -- --program mat-mul 
	-cd jolt && ../utils/target/debug/utils --bench-name jolt-mat-mul --bin target/release/jolt-benchmarks --bench-arg $(word 4, $(MATMUL_ARGS)) --bench-mem -- --program mat-mul 

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
	cd sp1/sha2-precompile && cargo prove build
	cd sp1/sha2-chain-precompile && cargo prove build
	cd sp1/sha3-precompile && cargo prove build
	cd sp1/sha3-chain-precompile && cargo prove build
	cd sp1/ec && cargo prove build
	cd sp1/ec-precompile && cargo prove build
	cd sp1 && cargo build --release

bench-sp1:
	make build-sp1
	make bench-sp1-fib
	make bench-sp1-sha2
	make bench-sp1-sha2-chain
	make bench-sp1-sha3
	make bench-sp1-sha3-chain
	make bench-sp1-mat-mul
	make bench-sp1-binary-search
	make bench-sp1-sha2-precompile
	make bench-sp1-sha3-precompile
	make bench-sp1-sha2-chain-precompile
	make bench-sp1-sha3-chain-precompile
	make bench-sp1-ec
	make bench-sp1-ec-precompile

bench-sp1-time:
	make build-sp1
	make bench-sp1-fib-time
	make bench-sp1-sha2-time
	make bench-sp1-sha2-chain-time
	make bench-sp1-sha3-time
	make bench-sp1-sha3-chain-time
	make bench-sp1-mat-mul-time
	make bench-sp1-binary-search-time
	make bench-sp1-sha2-precompile-time
	make bench-sp1-sha3-precompile-time
	make bench-sp1-sha2-chain-precompile-time
	make bench-sp1-sha3-chain-precompile-time
	make bench-sp1-ec-time
	make bench-sp1-ec-precompile-time

bench-sp1-fib:
	make bench-sp1-fib-time
	make bench-sp1-fib-mem

bench-sp1-ec:
	make bench-sp1-ec-time
	#make bench-sp1-ec-mem

bench-sp1-ec-precompile:
	make bench-sp1-ec-precompile-time
	#make bench-sp1-ec-precompile-mem

bench-sp1-sha2:
	make bench-sp1-sha2-time
	make bench-sp1-sha2-mem

bench-sp1-sha2-chain:
	make bench-sp1-sha2-chain-time
	make bench-sp1-sha2-chain-mem

bench-sp1-sha3:
	make bench-sp1-sha3-time
	make bench-sp1-sha3-mem

bench-sp1-sha3-chain:
	make bench-sp1-sha3-chain-time
	make bench-sp1-sha3-chain-mem

bench-sp1-mat-mul:
	make bench-sp1-mat-mul-time
	make bench-sp1-mat-mul-mem

bench-sp1-binary-search:
	make bench-sp1-binary-search-time
	make bench-sp1-binary-search-mem

bench-sp1-sha2-precompile:
	make bench-sp1-sha2-precompile-time
	# make bench-sp1-sha2-precompile-mem

bench-sp1-sha3-precompile:
	make bench-sp1-sha3-precompile-time
	# make bench-sp1-sha3-precompile-mem

bench-sp1-sha2-chain-precompile:
	make bench-sp1-sha2-chain-precompile-time
	# make bench-sp1-sha2-chain-precompile-mem

bench-sp1-sha3-chain-precompile:
	make bench-sp1-sha3-chain-precompile-time
	# make bench-sp1-sha3-chain-precompile-mem

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

bench-sp1-ec-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd --bin target/release/sp1-script --bench-arg $(word 1, $(ECADD_ARGS)) -- --program ecadd
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd --bin target/release/sp1-script --bench-arg $(word 2, $(ECADD_ARGS)) -- --program ecadd
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd --bin target/release/sp1-script --bench-arg $(word 3, $(ECADD_ARGS)) -- --program ecadd
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd --bin target/release/sp1-script --bench-arg $(word 4, $(ECADD_ARGS)) -- --program ecadd

bench-sp1-ec-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd --bin target/release/sp1-script --bench-arg $(word 1, $(ECADD_ARGS)) --bench-mem -- --program ecadd
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd --bin target/release/sp1-script --bench-arg $(word 2, $(ECADD_ARGS)) --bench-mem -- --program ecadd
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd --bin target/release/sp1-script --bench-arg $(word 3, $(ECADD_ARGS)) --bench-mem -- --program ecadd
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd --bin target/release/sp1-script --bench-arg $(word 4, $(ECADD_ARGS)) --bench-mem -- --program ecadd

bench-sp1-ec-precompile-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(ECADD_ARGS)) -- --program ecadd-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(ECADD_ARGS)) -- --program ecadd-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(ECADD_ARGS)) -- --program ecadd-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(ECADD_ARGS)) -- --program ecadd-precompile

bench-sp1-ec-precompile-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(ECADD_ARGS)) --bench-mem -- --program ecadd-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(ECADD_ARGS)) --bench-mem -- --program ecadd-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(ECADD_ARGS)) --bench-mem -- --program ecadd-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-ecadd-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(ECADD_ARGS)) --bench-mem -- --program ecadd-precompile

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

bench-sp1-sha2-chain-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) -- --program sha2-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) -- --program sha2-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) -- --program sha2-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) -- --program sha2-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) -- --program sha2-chain

bench-sp1-sha2-chain-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain

bench-sp1-sha2-precompile-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_ARGS)) -- --program sha2-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_ARGS)) -- --program sha2-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_ARGS)) -- --program sha2-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_ARGS)) -- --program sha2-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_ARGS)) -- --program sha2-precompile

bench-sp1-sha2-precompile-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_ARGS)) --bench-mem -- --program sha2-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_ARGS)) --bench-mem -- --program sha2-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_ARGS)) --bench-mem -- --program sha2-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_ARGS)) --bench-mem -- --program sha2-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-precompile --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_ARGS)) --bench-mem -- --program sha2-precompile

bench-sp1-sha2-chain-precompile-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) -- --program sha2-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) -- --program sha2-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) -- --program sha2-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) -- --program sha2-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) -- --program sha2-chain-precompile

bench-sp1-sha2-chain-precompile-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha2-chain-precompile --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha2-chain-precompile

bench-sp1-sha3-precompile-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_ARGS)) -- --program sha3-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_ARGS)) -- --program sha3-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_ARGS)) -- --program sha3-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_ARGS)) -- --program sha3-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_ARGS)) -- --program sha3-precompile

bench-sp1-sha3-precompile-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_ARGS)) --bench-mem -- --program sha3-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_ARGS)) --bench-mem -- --program sha3-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_ARGS)) --bench-mem -- --program sha3-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_ARGS)) --bench-mem -- --program sha3-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-precompile --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_ARGS)) --bench-mem -- --program sha3-precompile

bench-sp1-sha3-chain-precompile-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) -- --program sha3-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) -- --program sha3-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) -- --program sha3-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) -- --program sha3-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) -- --program sha3-chain-precompile

bench-sp1-sha3-chain-precompile-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain-precompile
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain-precompile --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain-precompile

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

bench-sp1-sha3-chain-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) -- --program sha3-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) -- --program sha3-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) -- --program sha3-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) -- --program sha3-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) -- --program sha3-chain

bench-sp1-sha3-chain-mem:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 1, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 2, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 3, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 4, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-sha3-chain --bin target/release/sp1-script --bench-arg $(word 5, $(SHA_CHAIN_ARGS)) --bench-mem -- --program sha3-chain

bench-sp1-mat-mul-time:
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 10 -- --program mat-mul
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 20 -- --program mat-mul
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 40 -- --program mat-mul
	-cd sp1 && ../utils/target/debug/utils --bench-name sp1-mat-mul --bin target/release/sp1-script --bench-arg 60 -- --program mat-mul

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
	make bench-risczero-sha2
	make bench-risczero-sha3
	make bench-risczero-mat-mul
	make bench-risczero-fib
	make bench-risczero-binary-search
	make bench-risczero-sha2-chain
	make bench-risczero-sha3-chain
	make bench-risczero-sha2-precompile
	# make bench-risczero-sha3-precompile
	make bench-risczero-sha2-chain-precompile
	# make bench-risczero-sha3-chain-precompile
	make bench-risczero-ecadd
	make bench-risczero-ecadd-precompile

build-risczero:
	cd risczero/sha2-chain && cargo build --release
	cd risczero/binary-search && cargo build --release
	cd risczero/fibonacci && cargo build --release
	cd risczero/ec && cargo build --release
	cd risczero/ec-precompile && cargo build --release
	cd risczero/sha3-chain && cargo build --release
	cd risczero/sha2 && cargo build --release
	cd risczero/sha3 && cargo build --release
	cd risczero/mat-mul && cargo build --release
	cd risczero/sha2-chain-precompile && cargo build --release
	# cd risczero/sha3-chain-precompile && cargo build --release
	cd risczero/sha2-precompile && cargo build --release
	# cd risczero/sha3-precompile && cargo build --release

bench-risczero-mat-mul:
	make bench-risczero-mat-mul-time
	# make bench-risczero-mat-mul-mem

bench-risczero-mat-mul-time:
	-cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg $(word 1, $(MATMUL_ARGS)) 
	-cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg $(word 2, $(MATMUL_ARGS)) 
	-cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg $(word 3, $(MATMUL_ARGS)) 
	-cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg $(word 4, $(MATMUL_ARGS))

bench-risczero-sha2:
	make bench-risczero-sha2-time
	# make bench-risczero-sha2-mem

bench-risczero-sha2-time:
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 1, $(SHA_ARGS))
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 2, $(SHA_ARGS))
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 3, $(SHA_ARGS))
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 4, $(SHA_ARGS))
	-cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg $(word 5, $(SHA_ARGS))

bench-risczero-sha2-precompile:
	make bench-risczero-sha2-precompile-time

bench-risczero-sha2-precompile-time:
	-cd risczero/sha2-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-precompile --bin target/release/host --bench-arg $(word 1, $(SHA_ARGS))
	-cd risczero/sha2-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-precompile --bin target/release/host --bench-arg $(word 2, $(SHA_ARGS))
	-cd risczero/sha2-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-precompile --bin target/release/host --bench-arg $(word 3, $(SHA_ARGS))
	-cd risczero/sha2-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-precompile --bin target/release/host --bench-arg $(word 4, $(SHA_ARGS))
	-cd risczero/sha2-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-precompile --bin target/release/host --bench-arg $(word 5, $(SHA_ARGS))

# bench-risczero-sha3-precompile:
# 	make bench-risczero-sha3-precompile-time

# bench-risczero-sha3-precompile-time:
# 	-cd risczero/sha3-precompile && ../../utils/target/debug/utils --bench-name risczero-sha3-precompile --bin target/release/host --bench-arg $(word 1, $(SHA_ARGS))
# 	-cd risczero/sha3-precompile && ../../utils/target/debug/utils --bench-name risczero-sha3-precompile --bin target/release/host --bench-arg $(word 2, $(SHA_ARGS))
# 	-cd risczero/sha3-precompile && ../../utils/target/debug/utils --bench-name risczero-sha3-precompile --bin target/release/host --bench-arg $(word 3, $(SHA_ARGS))
# 	-cd risczero/sha3-precompile && ../../utils/target/debug/utils --bench-name risczero-sha3-precompile --bin target/release/host --bench-arg $(word 4, $(SHA_ARGS))
# 	-cd risczero/sha3-precompile && ../../utils/target/debug/utils --bench-name risczero-sha3-precompile --bin target/release/host --bench-arg $(word 5, $(SHA_ARGS))

bench-risczero-sha2-chain-precompile:
	make bench-risczero-sha2-chain-precompile-time

bench-risczero-sha2-chain-precompile-time:
	-cd risczero/sha2-chain-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-chain-precompile --bin target/release/host --bench-arg $(word 1, $(SHA_CHAIN_ARGS))
	-cd risczero/sha2-chain-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-chain-precompile --bin target/release/host --bench-arg $(word 2, $(SHA_CHAIN_ARGS))
	-cd risczero/sha2-chain-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-chain-precompile --bin target/release/host --bench-arg $(word 3, $(SHA_CHAIN_ARGS))
	-cd risczero/sha2-chain-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-chain-precompile --bin target/release/host --bench-arg $(word 4, $(SHA_CHAIN_ARGS))
	-cd risczero/sha2-chain-precompile && ../../utils/target/debug/utils --bench-name risczero-sha2-chain-precompile --bin target/release/host --bench-arg $(word 5, $(SHA_CHAIN_ARGS))

bench-risczero-sha2-chain:
	make bench-risczero-sha2-chain-time
	# make bench-risczero-sha2-chain-mem

bench-risczero-sha2-chain-time:
	-cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg $(word 1, $(SHA_CHAIN_ARGS))
	-cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg $(word 2, $(SHA_CHAIN_ARGS))
	-cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg $(word 3, $(SHA_CHAIN_ARGS))
	-cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg $(word 4, $(SHA_CHAIN_ARGS))
	-cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg $(word 5, $(SHA_CHAIN_ARGS))

bench-risczero-sha3:
	make bench-risczero-sha3-time
	# make bench-risczero-sha3-mem

bench-risczero-sha3-time:
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 1, $(SHA_ARGS))
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 2, $(SHA_ARGS))
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 3, $(SHA_ARGS))
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 4, $(SHA_ARGS))
	-cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg $(word 5, $(SHA_ARGS))

bench-risczero-sha3-chain:
	make bench-risczero-sha3-chain-time
	# make bench-risczero-sha3-chain-mem

bench-risczero-sha3-chain-time:
	-cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg $(word 1, $(SHA_CHAIN_ARGS))
	-cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg $(word 2, $(SHA_CHAIN_ARGS))
	-cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg $(word 3, $(SHA_CHAIN_ARGS))
	-cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg $(word 4, $(SHA_CHAIN_ARGS))
	-cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg $(word 5, $(SHA_CHAIN_ARGS))

bench-risczero-fib:
	make bench-risczero-fib-time
	# make bench-risczero-fib-mem

bench-risczero-fib-time:
	cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 1, $(FIB_ARGS))
	cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 2, $(FIB_ARGS))
	cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 3, $(FIB_ARGS))
	cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 4, $(FIB_ARGS))

# bench-risczero-fib-mem:
	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 1, $(FIB_ARGS)) --bench-mem
	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 2, $(FIB_ARGS)) --bench-mem
	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 3, $(FIB_ARGS)) --bench-mem
	# cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg $(word 4, $(FIB_ARGS)) --bench-mem

bench-risczero-ecadd:
	make bench-risczero-ecadd-time

bench-risczero-ecadd-time:
	cd risczero/ec && ../../utils/target/debug/utils --bench-name risczero-ecadd --bin target/release/host --bench-arg $(word 1, $(ECADD_ARGS))
	cd risczero/ec && ../../utils/target/debug/utils --bench-name risczero-ecadd --bin target/release/host --bench-arg $(word 2, $(ECADD_ARGS))
	cd risczero/ec && ../../utils/target/debug/utils --bench-name risczero-ecadd --bin target/release/host --bench-arg $(word 3, $(ECADD_ARGS))
	cd risczero/ec && ../../utils/target/debug/utils --bench-name risczero-ecadd --bin target/release/host --bench-arg $(word 4, $(ECADD_ARGS))

bench-risczero-ecadd-precompile:
	make bench-risczero-ecadd-precompile-time

bench-risczero-ecadd-precompile-time:
	cd risczero/ec-precompile && ../../utils/target/debug/utils --bench-name risczero-ecadd-precompile --bin target/release/ec-precompile --bench-arg $(word 1, $(ECADD_ARGS))
	cd risczero/ec-precompile && ../../utils/target/debug/utils --bench-name risczero-ecadd-precompile --bin target/release/ec-precompile --bench-arg $(word 2, $(ECADD_ARGS))
	cd risczero/ec-precompile && ../../utils/target/debug/utils --bench-name risczero-ecadd-precompile --bin target/release/ec-precompile --bench-arg $(word 3, $(ECADD_ARGS))
	cd risczero/ec-precompile && ../../utils/target/debug/utils --bench-name risczero-ecadd-precompile --bin target/release/ec-precompile --bench-arg $(word 4, $(ECADD_ARGS))

bench-risczero-binary-search:
	make bench-risczero-binary-search-time
	# make bench-risczero-binary-search-mem

bench-risczero-binary-search-time:
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 1, $(BINARY_SEARCH_ARGS))
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 2, $(BINARY_SEARCH_ARGS))
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 3, $(BINARY_SEARCH_ARGS))
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 4, $(BINARY_SEARCH_ARGS))
	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 5, $(BINARY_SEARCH_ARGS))

# bench-risczero-binary-search-mem:
# 	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 1, $(BINARY_SEARCH_ARGS)) --bench-mem
# 	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 2, $(BINARY_SEARCH_ARGS)) --bench-mem
# 	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 3, $(BINARY_SEARCH_ARGS)) --bench-mem
# 	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 4, $(BINARY_SEARCH_ARGS)) --bench-mem
# 	-cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg $(word 5, $(BINARY_SEARCH_ARGS)) --bench-mem


bench-risczero-mem:
	make build-risczero
	make bench-risczero-sha2-mem
	make bench-risczero-sha3-mem
	make bench-risczero-mat-mul-mem
	make bench-risczero-fib-mem
	make bench-risczero-binary-search-mem
	make bench-risczero-sha2-chain-mem
	make bench-risczero-sha3-chain-mem
	make bench-risczero-ecadd-mem
	make bench-risczero-ecadd-precompile-mem

bench-risczero-binary-search-mem:
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg 128"' /benchmark_outputs/risczero-binary-search.csv 128
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg 256"' /benchmark_outputs/risczero-binary-search.csv 256
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg 512"' /benchmark_outputs/risczero-binary-search.csv 512
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg 1024"' /benchmark_outputs/risczero-binary-search.csv 1024
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/binary-search && ../../utils/target/debug/utils --bench-name risczero-binary-search --bin target/release/host --bench-arg 2048"' /benchmark_outputs/risczero-binary-search.csv 2048

bench-risczero-fib-mem:  
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg 100"' risczero-fib.csv 100
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg 1000"' risczero-fib.csv 1000
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg 10000"' risczero-fib.csv 10000
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/fibonacci && ../../utils/target/debug/utils --bench-name risczero-fib --bin target/release/host --bench-arg 50000"' risczero-fib.csv 50000

bench-risczero-ecadd-mem:
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/ec && ../../utils/target/debug/utils --bench-name risczero-ecadd --bin target/release/host --bench-arg $(word 1, $(ECADD_ARGS))"' ./benchmark_outputs/risczero-ecadd.csv $(word 1, $(ECADD_ARGS))
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/ec && ../../utils/target/debug/utils --bench-name risczero-ecadd --bin target/release/host --bench-arg $(word 2, $(ECADD_ARGS))"' ./benchmark_outputs/risczero-ecadd.csv $(word 2, $(ECADD_ARGS))
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/ec && ../../utils/target/debug/utils --bench-name risczero-ecadd --bin target/release/host --bench-arg $(word 3, $(ECADD_ARGS))"' ./benchmark_outputs/risczero-ecadd.csv $(word 3, $(ECADD_ARGS))
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/ec && ../../utils/target/debug/utils --bench-name risczero-ecadd --bin target/release/host --bench-arg $(word 4, $(ECADD_ARGS))"' ./benchmark_outputs/risczero-ecadd.csv $(word 4, $(ECADD_ARGS))

bench-risczero-ecadd-precompile-mem:
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/ec-precompile && ../../utils/target/debug/utils --bench-name risczero-ecadd-precompile --bin target/release/ec-precompile --bench-arg $(word 1, $(ECADD_ARGS))"' ./benchmark_outputs/risczero-ecadd-precompile.csv $(word 1, $(ECADD_ARGS))
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/ec-precompile && ../../utils/target/debug/utils --bench-name risczero-ecadd-precompile --bin target/release/ec-precompile --bench-arg $(word 2, $(ECADD_ARGS))"' ./benchmark_outputs/risczero-ecadd-precompile.csv $(word 2, $(ECADD_ARGS))
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/ec-precompile && ../../utils/target/debug/utils --bench-name risczero-ecadd-precompile --bin target/release/ec-precompile --bench-arg $(word 3, $(ECADD_ARGS))"' ./benchmark_outputs/risczero-ecadd-precompile.csv $(word 3, $(ECADD_ARGS))
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/ec-precompile && ../../utils/target/debug/utils --bench-name risczero-ecadd-precompile --bin target/release/ec-precompile --bench-arg $(word 4, $(ECADD_ARGS))"' ./benchmark_outputs/risczero-ecadd-precompile.csv $(word 4, $(ECADD_ARGS))

bench-risczero-mat-mul-mem:
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg 100"' risczero-mat-mul.csv 100
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg 500"' risczero-mat-mul.csv 500
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg 1000"' risczero-mat-mul.csv 1000
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/mat-mul && ../../utils/target/debug/utils --bench-name risczero-mat-mul --bin target/release/host --bench-arg 10000"' risczero-mat-mul.csv 10000

bench-risczero-sha2-mem:
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg 32"' risczero-sha2.csv 32
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg 256"' risczero-sha2.csv 256
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg 512"' risczero-sha2.csv 512
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg 1024"' risczero-sha2.csv 1024
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2 && ../../utils/target/debug/utils --bench-name risczero-sha2 --bin target/release/host --bench-arg 2048"' risczero-sha2.csv 2048

bench-risczero-sha3-mem:
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg 32"' risczero-sha3.csv 32
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg 256"' risczero-sha3.csv 256
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg 512"' risczero-sha3.csv 512
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg 1024"' risczero-sha3.csv 1024
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3 && ../../utils/target/debug/utils --bench-name risczero-sha3 --bin target/release/host --bench-arg 2048"' risczero-sha3.csv 2048

bench-risczero-sha2-chain-mem:
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg 230"' risczero-sha2-chain.csv 230
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg 460"' risczero-sha2-chain.csv 460
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg 920"' risczero-sha2-chain.csv 920
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg 1840"' risczero-sha2-chain.csv 1840
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha2-chain && ../../utils/target/debug/utils --bench-name risczero-sha2-chain --bin target/release/host --bench-arg 3680"' risczero-sha2-chain.csv 3680

bench-risczero-sha3-chain-mem:
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg 230"' risczero-sha3-chain.csv 230
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg 460"' risczero-sha3-chain.csv 460
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg 920"' risczero-sha3-chain.csv 920
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg 1840"' risczero-sha3-chain.csv 1840
	./bench_peak_memory.sh './mem.sh bash -c "cd risczero/sha3-chain && ../../utils/target/debug/utils --bench-name risczero-sha3-chain --bin target/release/host --bench-arg 3680"' risczero-sha3-chain.csv 3680


#####
# stone
#####

bench-stone:
	make build-stone
	make bench-stone-time
	make bench-stone-mem

bench-stone-time:
	make build-stone
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
	cd stone/common && cargo build --release
	cd stone/binary-search && cargo build --release
	cd stone/fibonacci && cargo build --release
	cd stone/keccak && cargo build --release
	cd stone/keccak-builtin && cargo build --release
	cd stone/keccak-builtin-chain && cargo build --release
	cd stone/sha256 && cargo build --release
	cd stone/sha256-chain && cargo build --release
	cd stone/mat-mul && cargo build --release
	make build-stone-steps

bench-stone-sha256:
	make bench-stone-sha256-time
	make bench-stone-sha256-mem

bench-stone-keccak:
	make bench-stone-keccak-time
	make bench-stone-keccak-mem

bench-stone-keccak-builtin:
	make bench-stone-keccak-builtin-time
	make bench-stone-keccak-builtin-mem

bench-stone-keccak-builtin-chain:
	make bench-stone-keccak-builtin-chain-time
	make bench-stone-keccak-builtin-chain-mem

bench-stone-fib:
	make bench-stone-fib-time
	make bench-stone-fib-mem

bench-stone-binary-search:
	make bench-stone-binary-search-time
	make bench-stone-binary-search-mem

bench-stone-mat:
	make bench-stone-mat-time
	make bench-stone-mat-mem

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
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 10
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 20
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 40
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 60

bench-stone-mat-memory:
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 10 --bench-mem
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 20 --bench-mem
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 40 --bench-mem
	-cd stone/mat-mul && ../../utils/target/debug/utils --bench-name stone-mat-mul --bin target/release/stone --bench-arg 60 --bench-mem

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
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 37
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 74
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 148
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 295
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 589

bench-stone-keccak-builtin-chain-mem:
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 37 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 74 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 148 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 295 --bench-mem
	-cd stone/keccak-builtin && ../../utils/target/debug/utils --bench-name stone-keccak-builtin-chain --bin target/release/stone --bench-arg 589 --bench-mem

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

build-stone-steps:
	cd stone && git clone https://github.com/lambdaclass/cairo-vm.git
	cd stone/cairo-vm/cairo1-run && make deps


#####
# stwo
#####

bench-stwo:
	make build-stwo
	make bench-stwo-time
	make bench-stwo-mem

build-stwo:
	cd stwo && cargo build --release
	cd stwo/fibonacci && scarb build
	# cd stwo && git clone https://github.com/starkware-libs/stwo-cairo.git
	cd stwo/stwo-cairo/stwo_cairo_prover && cargo build --release
	# cd stwo/stwo-cairo/stwo_cairo_verifier && cargo build --release

bench-stwo-time:
	make bench-stwo-fibonacci-time

bench-stwo-mem:
	make bench-stwo-fibonacci-mem

bench-stwo-fibonacci-time:
	cd stwo && ../utils/target/debug/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg $(word 1, $(FIB_ARGS)) -- --program fib
	cd stwo && ../utils/target/debug/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg $(word 2, $(FIB_ARGS)) -- --program fib
	cd stwo && ../utils/target/debug/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg $(word 3, $(FIB_ARGS)) -- --program fib
	cd stwo && ../utils/target/debug/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg $(word 4, $(FIB_ARGS)) -- --program fib

bench-stwo-mem:
	cd stwo && ../utils/target/debug/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg $(word 1, $(FIB_ARGS)) --bench-mem -- --program fib 
	cd stwo && ../utils/target/debug/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg $(word 2, $(FIB_ARGS)) --bench-mem -- --program fib
	cd stwo && ../utils/target/debug/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg $(word 3, $(FIB_ARGS)) --bench-mem -- --program fib
	cd stwo && ../utils/target/debug/utils --bench-name stwo-fib --bin target/release/stwo-script --bench-arg $(word 4, $(FIB_ARGS)) --bench-mem -- --program fib