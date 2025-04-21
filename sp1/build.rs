use sp1_build::build_program_with_args;

fn main() {
    build_program_with_args("fib", Default::default());
    build_program_with_args("sha2", Default::default());
    build_program_with_args("sha2-precompile", Default::default());
    build_program_with_args("sha2-chain", Default::default());
    build_program_with_args("sha2-chain-precompile", Default::default());
    build_program_with_args("sha3-chain", Default::default());
    build_program_with_args("sha3-chain-precompile", Default::default());
    build_program_with_args("sha3", Default::default());
    build_program_with_args("sha3-precompile", Default::default());
    build_program_with_args("mat-mul", Default::default());
    build_program_with_args("ec", Default::default());
    build_program_with_args("ec-precompile", Default::default());
}
