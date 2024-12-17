use clap::{Parser};
use common::{prove_and_verify, Cli};

fn main() {
    // read args from cli
    let cli = Cli::parse();

    run(cli.n, cli.bench_mem);
}

fn run(n: u32, bench_mem: bool) {
    let command = "stone-cli";
    let program_path = "programs/binary_search.cairo".to_string();
    
    let array: Vec<u32> = (1..=n).collect();
    let program_input = format!(
        "[{}]",
        array.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(" ")
    );

    let output_file = "proof.json".to_string();
    let args = if bench_mem {
        vec![
            "prove",
            "--cairo_program",
            &program_path,
            "--program_input",
            &program_input,
            "--output",
            &output_file,
            "--stone_version",
            "v6",
            "--bench-memory",
            "true",
        ]
    }
    else {
        vec![
            "prove",
            "--cairo_program",
            &program_path,
            "--program_input",
            &program_input,
            "--output",
            &output_file,
            "--stone_version",
            "v6",
        ]
    };

    prove_and_verify(command, args.to_vec(), output_file.clone());
}

