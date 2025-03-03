import marimo

__generated_with = "0.11.8"
app = marimo.App(width="medium")


@app.cell
def _(mo):
    mo.md(
        r"""
        # zkvm benchmarks

        - Stone benchmarks were generated using the `dynamic` layout with the following configurations:
            - Parameters - `fri_step_list` and `last_layer_degree_bound` change dependeing on the size of the computation but other parameters remain same
                ```
                {
                    "field": "PrimeField0",
                    "channel_hash": "keccak256",
                    "commitment_hash": "keccak256_masked160_lsb",
                    "n_verifier_friendly_commitment_layers": 0,
                    "pow_hash": "keccak256",
                    "statement": {
                        "page_hash": "pedersen"
                    },
                    "stark": {
                        "fri": {
                            "fri_step_list": [
                                0,
                                3,
                                3,
                                3,
                                3,
                                2
                            ],
                            "last_layer_degree_bound": 64,
                            "n_queries": 16,
                            "proof_of_work_bits": 20
                        },
                        "log_n_cosets": 5
                    },
                    "use_extension_field": false,
                    "verifier_friendly_channel_updates": false,
                    "verifier_friendly_commitment_hash": "poseidon3"
                }
                ```
            - Prover Config
                ```
                {
                    "cached_lde_config": {
                        "store_full_lde": true,
                        "use_fft_for_eval": false
                    },
                    "constraint_polynomial_task_size": 256,
                    "n_out_of_memory_merkle_layers": 0,
                    "table_prover_n_tasks_per_segment": 32
                }
                ```
        """
    )
    return


@app.cell
def _(mo):
    mo.md("""## Machine Specification""")
    return


@app.cell
def _():
    import marimo as mo
    from pathlib import Path
    from IPython.display import display, HTML

    with mo.redirect_stdout():
        txt_folder = Path("./machine_info/")

        if not txt_folder.exists():
            display(HTML("<p style='font-size:20px; color:red;'>The folder containing .txt files does not exist. Please ensure the path is correct.</p>"))
        else:
            txt_files = list(txt_folder.glob("*.txt"))

            if not txt_files:
                display(HTML("<p style='font-size:20px; color:blue;'>No .txt files found in the specified folder.</p>"))
            else:
                for txt_file in txt_files:
                    with txt_file.open("r") as file:
                        content = file.read()

                    display(HTML(f"<pre style='font-size:14px; color:black;'>{content}</pre>"))
    return (
        HTML,
        Path,
        content,
        display,
        file,
        mo,
        txt_file,
        txt_files,
        txt_folder,
    )


@app.cell
def _(mo):
    import os
    import pandas as pd
    import matplotlib.pyplot as plt
    import itertools
    import numpy as np

    # Function to preprocess the dataframes
    def preprocess_data(df, column_name):
        """Preprocess the dataframe by dropping NaN values and converting units."""
        df = df.dropna(subset=["n", column_name])
        df = df.sort_values(by="n").reset_index(drop=True)

        # Convert units if applicable
        if "prover time(ms)" in column_name:
            df[column_name] = df[column_name] / 1000  # Convert ms to s
        elif "proof size(bytes)" in column_name:
            df[column_name] = df[column_name] / 1000  # Convert bytes to KB

        return df[["n", column_name]]

    # Function to combine benchmark data
    def combine_benchmark(bench_tuple, column_name):
        """Combine benchmark data for a given column from multiple sources."""
        bench_name, is_precompile, is_builtin = bench_tuple
        file_paths = {
            "jolt": f'./benchmark_outputs/jolt-{bench_name}.csv',
            "sp1": f'./benchmark_outputs/sp1-{bench_name}.csv',
            "r0": f'./benchmark_outputs/risczero-{bench_name}.csv',
            "stone": f'./benchmark_outputs/stone-{bench_name}.csv',
            "stwo": f'./benchmark_outputs/stwo-{bench_name}.csv',
        }

        # if column_name == 'prover time(ms)':
        #     file_paths["stwo"] = f'./benchmark_outputs/stwo-{bench_name}.csv'

        if is_precompile:
            file_paths["sp1-precompile"] = f'./benchmark_outputs/sp1-{bench_name}-precompile.csv'
            file_paths["r0-precompile"] = f'./benchmark_outputs/risczero-{bench_name}-precompile.csv'

        if bench_name == 'sha3-chain' and is_builtin:
            file_paths.pop("stone", None)
            # file_paths["stone-builtin"] = f'./benchmark_outputs/stone-{bench_name}-builtin.csv'

        combined_df = None  # Start with an empty DataFrame

        for name, path in file_paths.items():
            df = preprocess_data(pd.read_csv(path), column_name)

            # Rename the column to just the benchmark name (jolt, sp1, r0, stone)
            df.rename(columns={column_name: name}, inplace=True)

            # Merge all data on 'n'
            if combined_df is None:
                combined_df = df
            else:
                combined_df = pd.merge(combined_df, df, on="n", how="outer")

        return combined_df

    def plot_benchmark(df, title, y_label, bench_tuple, column_name):
        """Plot the benchmark data with dynamically chosen colors and markers, then save it as a PNG."""
        bench_name, _, is_builtin = bench_tuple

        # Define a set of markers and colors, then cycle through them if needed
        marker_list = ['o', 's', 'D', '^', 'v', '*', 'P', 'X']
        color_list = ['b', 'r', 'g', 'm', 'c', 'y', 'k', '#ff7f0e']

        markers = itertools.cycle(marker_list)  # Cycle through markers if needed
        colors = itertools.cycle(color_list)  # Cycle through colors if needed

        plt.figure(figsize=(8, 6))

        for col in df.columns[1:]:  # Skip "n" column
            non_zero = df[col] != 0
            plt.plot(df["n"][non_zero], df[col][non_zero], 
                     marker=next(markers), color=next(colors), label=col, linestyle='-')

        if bench_name == 'sha3' and is_builtin:
            path = f'./benchmark_outputs/stone-{bench_name}-builtin.csv'
            stone_df = preprocess_data(pd.read_csv(path), column_name)
            stone_df["n"] *= 200  # Multiply n column by 200
            plt.plot(stone_df["n"], stone_df[column_name], marker='h', color='#8B0000', label="stone-builtin", linestyle='-')

        if bench_name == 'sha3-chain' and is_builtin:
            path = f'./benchmark_outputs/stone-{bench_name}-builtin.csv'
            stone_df = preprocess_data(pd.read_csv(path), column_name)
            stone_df["n"] = np.ceil(stone_df["n"] * (200 / 32))
            plt.plot(stone_df["n"], stone_df[column_name], marker='h', color='#8B0000', label="stone-builtin", linestyle='-')

        plt.xlabel("n")
        plt.ylabel(y_label)
        plt.title(title)
        plt.yscale("log")
        plt.xscale("log")
        plt.legend()
        plt.grid(True, which="both", linestyle="--", linewidth=0.5)

        # Save the plot as a PNG file
        filename = f"./plots/{bench_name}_{title.replace(' ', '_').lower()}.png"
        plt.savefig(filename, dpi=300)
        plt.close()  # Close the figure to avoid displaying it

        return filename  # Return the filename of the saved plot

    def get_data(bench_tuple):
        prover_time_df = combine_benchmark(bench_tuple, "prover time(ms)")
        verifier_time_df = combine_benchmark(bench_tuple, "verifier time(ms)")
        proof_size_df = combine_benchmark(bench_tuple, "proof size(bytes)")
        cycle_count_df = combine_benchmark(bench_tuple, "cycle count")
        peak_memory_df = combine_benchmark(bench_tuple, "peak memory")
        return prover_time_df, verifier_time_df, proof_size_df, cycle_count_df, peak_memory_df

    def get_tables(bench_tuple):
        prover_time_df, verifier_time_df, proof_size_df, cycle_count_df, peak_memory_df = get_data(bench_tuple)
        prover_table = mo.ui.table(
            data=prover_time_df,
            label="Prover Time (s)",
            show_column_summaries = False,
            selection = None,
        )

        verifier_table = mo.ui.table(
            data=verifier_time_df,
            label="Verifier Time (ms)",
            show_column_summaries = False,
            selection = None,
        )

        proof_size_table = mo.ui.table(
            data=proof_size_df,
            label="Proof Size (KB)",
            show_column_summaries = False,
            selection = None,
        )

        cycle_count_table = mo.ui.table(
            data=cycle_count_df,
            label="Cycle Count",
            show_column_summaries = False,
            selection = None,
        )

        peak_memory_table = mo.ui.table(
            data=peak_memory_df,
            label="Peak Memory (GB)",
            show_column_summaries = False,
            selection = None,
        )
        return prover_table, verifier_table, proof_size_table, cycle_count_table, peak_memory_table

    def get_plots(bench_tuple):
        prover_time_df, verifier_time_df, proof_size_df, cycle_count_df, peak_memory_df = get_data(bench_tuple)
        prover_time_plot = plot_benchmark(prover_time_df, "Prover Time vs n", "Prover Time (s)", bench_tuple, "prover time(ms)")
        verifier_time_plot = plot_benchmark(verifier_time_df, "Verifier Time vs n", "Verifier Time (ms)", bench_tuple, "verifier time(ms)")
        proof_size_plot = plot_benchmark(proof_size_df, "Proof Size vs n", "Proof Size (KB)", bench_tuple, "proof size(bytes)")
        cycle_count_plot = plot_benchmark(cycle_count_df, "Cycle Count vs n", "Cycle Count", bench_tuple, "cycle count")
        peak_memory_plot = plot_benchmark(peak_memory_df, "Peak Memory vs n", "Peak Memory", bench_tuple, "peak memory")

        return prover_time_plot, verifier_time_plot, proof_size_plot, cycle_count_plot, peak_memory_plot


    plots_dir = "./plots/"
    os.makedirs(plots_dir, exist_ok=True)
    return (
        combine_benchmark,
        get_data,
        get_plots,
        get_tables,
        itertools,
        np,
        os,
        pd,
        plot_benchmark,
        plots_dir,
        plt,
        preprocess_data,
    )


@app.cell
def _(mo):
    mo.md(
        r"""
        ## Fibonacci
        Benchmark `n` Fibonacci iterations.
        """
    )
    return


@app.cell
def _(get_plots, get_tables):
    fib_tuple = ("fib", False, False)

    fib_prover_table, fib_verifier_table, fib_proof_size_table, fib_cycle_count_table, fib_peak_memory_table = get_tables(fib_tuple)

    fib_prover_time_plot, fib_verifier_time_plot, fib_proof_size_plot, fib_cycle_count_plot, fib_peak_memory_plot = get_plots(fib_tuple)
    return (
        fib_cycle_count_plot,
        fib_cycle_count_table,
        fib_peak_memory_plot,
        fib_peak_memory_table,
        fib_proof_size_plot,
        fib_proof_size_table,
        fib_prover_table,
        fib_prover_time_plot,
        fib_tuple,
        fib_verifier_table,
        fib_verifier_time_plot,
    )


@app.cell
def _(fib_prover_table, mo):
    mo.vstack([fib_prover_table])
    return


@app.cell
def _(fib_prover_time_plot, mo):
    mo.image(fib_prover_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(fib_verifier_table, mo):
    mo.vstack([fib_verifier_table])
    return


@app.cell
def _(fib_verifier_time_plot, mo):
    mo.image(fib_verifier_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(fib_proof_size_table, mo):
    mo.vstack([fib_proof_size_table])
    return


@app.cell
def _(fib_proof_size_plot, mo):
    mo.image(fib_proof_size_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(fib_cycle_count_table, mo):
    mo.vstack([fib_cycle_count_table])
    return


@app.cell
def _(fib_cycle_count_plot, mo):
    mo.image(fib_cycle_count_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _():
    # mo.vstack([fib_peak_memory_table])
    return


@app.cell
def _():
    # mo.image(fib_peak_memory_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo):
    mo.md(
        """
        ## Sha2

        Benchmark Sha256 hash of `n` bytes. For Stone, the [cairo implementation of sha256](https://github.com/cartridge-gg/cairo-sha256) by cartridge was used for benchmarking and for other zkvms [sha2 Rust crate](https://crates.io/crates/sha2) was used for benchmarking.
        """
    )
    return


@app.cell
def _(get_plots, get_tables):
    sha2_tuple = ("sha2", True, True)

    sha2_prover_table, sha2_verifier_table, sha2_proof_size_table, sha2_cycle_count_table, sha2_peak_memory_table = get_tables(sha2_tuple)

    sha2_prover_time_plot, sha2_verifier_time_plot, sha2_proof_size_plot, sha2_cycle_count_plot, sha2_peak_memory_plot = get_plots(sha2_tuple)
    return (
        sha2_cycle_count_plot,
        sha2_cycle_count_table,
        sha2_peak_memory_plot,
        sha2_peak_memory_table,
        sha2_proof_size_plot,
        sha2_proof_size_table,
        sha2_prover_table,
        sha2_prover_time_plot,
        sha2_tuple,
        sha2_verifier_table,
        sha2_verifier_time_plot,
    )


@app.cell
def _(mo, sha2_prover_table):
    mo.vstack([sha2_prover_table])
    return


@app.cell
def _(mo, sha2_prover_time_plot):
    mo.image(sha2_prover_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, sha2_verifier_table):
    mo.vstack([sha2_verifier_table])
    return


@app.cell
def _(mo, sha2_verifier_time_plot):
    mo.image(sha2_verifier_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, sha2_proof_size_table):
    mo.vstack([sha2_proof_size_table])
    return


@app.cell
def _(mo, sha2_proof_size_plot):
    mo.image(sha2_proof_size_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, sha2_cycle_count_table):
    mo.vstack([sha2_cycle_count_table])
    return


@app.cell
def _(mo, sha2_cycle_count_plot):
    mo.image(sha2_cycle_count_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _():
    # mo.vstack([sha2_peak_memory_table])
    return


@app.cell
def _():
    # mo.image(sha2_peak_memory_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo):
    mo.md(
        r"""
        ## Sha3

        Benchmark Keccak256 hash of `n` bytes. For Stone, the implementation of Keccak256 from stdlib as well as builtin was benchmarked.
        """
    )
    return


@app.cell
def _(get_plots, get_tables):
    sha3_tuple = ("sha3", True, True)

    sha3_prover_table, sha3_verifier_table, sha3_proof_size_table, sha3_cycle_count_table, sha3_peak_memory_table = get_tables(sha3_tuple)

    sha3_prover_time_plot, sha3_verifier_time_plot, sha3_proof_size_plot, sha3_cycle_count_plot, sha3_peak_memory_plot = get_plots(sha3_tuple)
    return (
        sha3_cycle_count_plot,
        sha3_cycle_count_table,
        sha3_peak_memory_plot,
        sha3_peak_memory_table,
        sha3_proof_size_plot,
        sha3_proof_size_table,
        sha3_prover_table,
        sha3_prover_time_plot,
        sha3_tuple,
        sha3_verifier_table,
        sha3_verifier_time_plot,
    )


@app.cell
def _(mo, sha3_prover_table):
    mo.vstack([sha3_prover_table])
    return


@app.cell
def _(mo, sha3_prover_time_plot):
    mo.image(sha3_prover_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, sha3_verifier_table):
    mo.vstack([sha3_verifier_table])
    return


@app.cell
def _(mo, sha3_verifier_time_plot):
    mo.image(sha3_verifier_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, sha3_proof_size_table):
    mo.vstack([sha3_proof_size_table])
    return


@app.cell
def _(mo, sha3_proof_size_plot):
    mo.image(sha3_proof_size_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, sha3_cycle_count_table):
    mo.vstack([sha3_cycle_count_table])
    return


@app.cell
def _(mo, sha3_cycle_count_plot):
    mo.image(sha3_cycle_count_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _():
    # mo.vstack([sha3_peak_memory_table])
    return


@app.cell
def _():
    # mo.image(sha3_peak_memory_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo):
    mo.md(r"""**Stone benchmark with Keccak Builtin**: The function call to the keccak builtin allows max 200 bytes per iteration. So the following benchmarks are hashing multiples of 200 byts.""")
    return


@app.cell
def _(mo, pd):
    path = f'./benchmark_outputs/stone-sha3-builtin.csv'
    stone_sha3_builtin_df = pd.read_csv(path)
    stone_sha3_builtin_df["n"] *= 200  # Multiply n column by 200
    stone_sha3_builtin_df.drop(columns=["peak memory"], inplace=True, errors='ignore')
    stone_sha3_builtin_table = mo.ui.table(
            data=stone_sha3_builtin_df,
            label="Stone benchmark with Keccak Builtin",
            show_column_summaries = False,
            selection = None,
    )
    mo.vstack([stone_sha3_builtin_table])
    return path, stone_sha3_builtin_df, stone_sha3_builtin_table


@app.cell
def _(mo):
    mo.md(
        r"""
        ## Sha3-Chain

        Benchmark Keccak256 hash of 32 bytes for `n` iteration.
        """
    )
    return


@app.cell
def _(get_plots, get_tables):
    sha3_chain_tuple = ("sha3-chain", True, True)

    sha3_chain_prover_table, sha3_chain_verifier_table, sha3_chain_proof_size_table, sha3_chain_cycle_count_table, sha3_chain_peak_memory_table = get_tables(sha3_chain_tuple)

    sha3_chain_prover_time_plot, sha3_chain_verifier_time_plot, sha3_chain_proof_size_plot, sha3_chain_cycle_count_plot, sha3_chain_peak_memory_plot = get_plots(sha3_chain_tuple)
    return (
        sha3_chain_cycle_count_plot,
        sha3_chain_cycle_count_table,
        sha3_chain_peak_memory_plot,
        sha3_chain_peak_memory_table,
        sha3_chain_proof_size_plot,
        sha3_chain_proof_size_table,
        sha3_chain_prover_table,
        sha3_chain_prover_time_plot,
        sha3_chain_tuple,
        sha3_chain_verifier_table,
        sha3_chain_verifier_time_plot,
    )


@app.cell
def _(mo, sha3_chain_prover_table):
    mo.vstack([sha3_chain_prover_table])
    return


@app.cell
def _(mo, sha3_chain_prover_time_plot):
    mo.image(sha3_chain_prover_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, sha3_chain_verifier_table):
    mo.vstack([sha3_chain_verifier_table])
    return


@app.cell
def _(mo, sha3_chain_verifier_time_plot):
    mo.image(sha3_chain_verifier_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, sha3_chain_proof_size_table):
    mo.vstack([sha3_chain_proof_size_table])
    return


@app.cell
def _(mo, sha3_chain_proof_size_plot):
    mo.image(sha3_chain_proof_size_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, sha3_chain_cycle_count_table):
    mo.vstack([sha3_chain_cycle_count_table])
    return


@app.cell
def _(mo, sha3_chain_cycle_count_plot):
    mo.image(sha3_chain_cycle_count_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _():
    # mo.vstack([sha3_chain_peak_memory_table])
    return


@app.cell
def _():
    # mo.image(sha3_chain_peak_memory_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mo):
    mo.md("""**Stone benchmark with Keccak Builtin**: The function call to the keccak builtin allows max 200 bytes per iteration. So the following benchmarks can be interpreted as hashing `200 * n` bytes data, such as `200 * 37 = 7400` and so on.""")
    return


@app.cell
def _(mo, pd):
    path_chain = f'./benchmark_outputs/stone-sha3-chain-builtin.csv'
    stone_sha3_chain_builtin_df = pd.read_csv(path_chain)
    stone_sha3_chain_builtin_df.drop(columns=["peak memory"], inplace=True, errors='ignore')
    stone_sha3_chain_builtin_table = mo.ui.table(
            data=stone_sha3_chain_builtin_df,
            label="Stone benchmark with Keccak-Chain Builtin",
            show_column_summaries = False,
            selection = None,
    )
    mo.vstack([stone_sha3_chain_builtin_table])
    return (
        path_chain,
        stone_sha3_chain_builtin_df,
        stone_sha3_chain_builtin_table,
    )


@app.cell
def _(mo):
    mo.md(
        r"""
        ## Matrix Multiplication

        Benchmark multplication of two matrices of size n x n.
        """
    )
    return


@app.cell
def _(get_plots, get_tables):
    mat_mul_tuple = ("mat-mul", False, False)

    mat_mul_prover_table, mat_mul_verifier_table, mat_mul_proof_size_table, mat_mul_cycle_count_table, mat_mul_peak_memory_table = get_tables(mat_mul_tuple)

    mat_mul_prover_time_plot, mat_mul_verifier_time_plot, mat_mul_proof_size_plot, mat_mul_cycle_count_plot, mat_mul_peak_memory_plot = get_plots(mat_mul_tuple)
    return (
        mat_mul_cycle_count_plot,
        mat_mul_cycle_count_table,
        mat_mul_peak_memory_plot,
        mat_mul_peak_memory_table,
        mat_mul_proof_size_plot,
        mat_mul_proof_size_table,
        mat_mul_prover_table,
        mat_mul_prover_time_plot,
        mat_mul_tuple,
        mat_mul_verifier_table,
        mat_mul_verifier_time_plot,
    )


@app.cell
def _(mat_mul_prover_table, mo):
    mo.vstack([mat_mul_prover_table])
    return


@app.cell
def _(mat_mul_prover_time_plot, mo):
    mo.image(mat_mul_prover_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mat_mul_verifier_table, mo):
    mo.vstack([mat_mul_verifier_table])
    return


@app.cell
def _(mat_mul_verifier_time_plot, mo):
    mo.image(mat_mul_verifier_time_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mat_mul_proof_size_table, mo):
    mo.vstack([mat_mul_proof_size_table])
    return


@app.cell
def _(mat_mul_proof_size_plot, mo):
    mo.image(mat_mul_proof_size_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _(mat_mul_cycle_count_table, mo):
    mo.vstack([mat_mul_cycle_count_table])
    return


@app.cell
def _(mat_mul_cycle_count_plot, mo):
    mo.image(mat_mul_cycle_count_plot, height=500, width=700, rounded=True)
    return


@app.cell
def _():
    # mo.vstack([mat_mul_peak_memory_table])
    return


@app.cell
def _():
    # mo.image(mat_mul_peak_memory_plot, height=500, width=700, rounded=True)
    return


if __name__ == "__main__":
    app.run()
