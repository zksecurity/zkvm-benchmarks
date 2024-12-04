bench-all:
	make bench-jolt
	make bench-sp1
	make bench-risczero
	make bench-stone

bench-jolt:
	cd jolt && cargo run --release

bench-sp1:
	make build-sp1
	cd sp1 && RUSTFLAGS="-C target-cpu=native" cargo run --release

build-sp1:
	cd sp1/fibonacci && cargo prove build
	cd sp1/sha2-chain && cargo prove build
	cd sp1/sha3-chain && cargo prove build
	cd sp1/sha2 && cargo prove build
	cd sp1/sha3 && cargo prove build
	cd sp1/bigmem && cargo prove build

bench-risczero:
	# cd risczero/sha2-chain && cargo run --release
	cd risczero/fibonacci && cargo run --release
	# cd risczero/sha3-chain && cargo run --release
	# cd risczero/sha2 && cargo run --release
	# cd risczero/sha3 && cargo run --release
	# cd risczero/bigmem && cargo run --release

bench-stone:
	cd stone && cargo run --release
