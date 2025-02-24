import marimo

__generated_with = "0.11.8"
app = marimo.App(width="medium")


@app.cell
def _(mo):
    mo.md(
        r"""
        # zkvm benchmarks

        - The peak heap memory was captured using `heaptrack`. Note that, RiscZero seems spawning the guest vm, so heaptrack can't collect the metrics in the same way. We used Linux cgroups (Control Groups) to compute the maximum memory usage for RiscZero.
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
        - For Sha2-chain benchmarks, Stone prover crashed due to insufficeint memory for higher number of iterations.
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
    with mo.redirect_stdout():

        # Importing necessary libraries
        from pathlib import Path

        # Define the folder containing your .txt files
        txt_folder = Path("./machine_info/")

        # Check if the folder exists
        if not txt_folder.exists():
            print("The folder containing .txt files does not exist. Please ensure the path is correct.")
        else:
            # Iterate through all .txt files in the folder
            txt_files = list(txt_folder.glob("*.txt"))

            if not txt_files:
                print("No .txt files found in the specified folder.")
            else:
                for txt_file in txt_files:
                    # Read the content of the file
                    with txt_file.open("r") as file:
                        content = str(file.read())

                    # Display its content
                    print(f"{content}\n")
    return Path, content, file, mo, txt_file, txt_files, txt_folder


@app.cell
def _(mo):
    import os
    import pandas as pd
    import matplotlib.pyplot as plt

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
    def combine_benchmark(bench_name, column_name):
        """Combine benchmark data for a given column from multiple sources."""
        file_paths = {
            "jolt": f'./benchmark_outputs/jolt-{bench_name}.csv',
            "sp1": f'./benchmark_outputs/sp1-{bench_name}.csv',
            "r0": f'./benchmark_outputs/risczero-{bench_name}.csv',
            "stone": f'./benchmark_outputs/stone-{bench_name}.csv'
        }

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

    def plot_benchmark(df, title, y_label, bench_name):
        """Plot the benchmark data with different colors and markers, and save it as a PNG."""
        markers = ['o', 's', 'D', '^']  # Different markers for each line
        colors = ['b', 'r', 'g', 'm']  # Different colors for each line

        plt.figure(figsize=(8, 6))

        for (col, color, marker) in zip(df.columns[1:], colors, markers):  # Skip "n" column
            non_zero = df[col] != 0
            plt.plot(df["n"][non_zero], df[col][non_zero], marker=marker, color=color, label=col, linestyle='-')

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

    bench_name = "fib"
    prover_time_df = combine_benchmark(bench_name, "prover time(ms)")
    verifier_time_df = combine_benchmark(bench_name, "verifier time(ms)")
    proof_size_df = combine_benchmark(bench_name, "proof size(bytes)")
    cycle_count_df = combine_benchmark(bench_name, "cycle count")
    peak_memory_df = combine_benchmark(bench_name, "peak memory")

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

    save_dir = "./plots/"
    os.makedirs(save_dir, exist_ok=True)

    prover_time_plot = plot_benchmark(prover_time_df, "Prover Time vs n", "Prover Time (s)", bench_name)
    verifier_time_plot = plot_benchmark(verifier_time_df, "Verifier Time vs n", "Verifier Time (ms)", bench_name)
    proof_size_plot = plot_benchmark(proof_size_df, "Proof Size vs n", "Proof Size (KB)", bench_name)
    cycle_count_plot = plot_benchmark(cycle_count_df, "Cycle Count vs n", "Cycle Count", bench_name)
    peak_memory_plot = plot_benchmark(peak_memory_df, "Peak Memory vs n", "Peak Memory", bench_name)
    return (
        bench_name,
        combine_benchmark,
        cycle_count_df,
        cycle_count_plot,
        cycle_count_table,
        os,
        pd,
        peak_memory_df,
        peak_memory_plot,
        peak_memory_table,
        plot_benchmark,
        plt,
        preprocess_data,
        proof_size_df,
        proof_size_plot,
        proof_size_table,
        prover_table,
        prover_time_df,
        prover_time_plot,
        save_dir,
        verifier_table,
        verifier_time_df,
        verifier_time_plot,
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
def _(mo, prover_table):
    mo.vstack([prover_table])
    return


@app.cell
def _(mo):
    mo.image("./plots/fib_prover_time_vs_n.png", height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, verifier_table):
    mo.vstack([verifier_table])
    return


@app.cell
def _(mo):
    mo.image("./plots/fib_verifier_time_vs_n.png", height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, proof_size_table):
    mo.vstack([proof_size_table])
    return


@app.cell
def _(mo):
    mo.image("./plots/fib_proof_size_vs_n.png", height=500, width=700, rounded=True)
    return


@app.cell
def _(cycle_count_table, mo):
    mo.vstack([cycle_count_table])
    return


@app.cell
def _(mo):
    mo.image("./plots/fib_cycle_count_vs_n.png", height=500, width=700, rounded=True)
    return


@app.cell
def _(mo, peak_memory_table):
    mo.vstack([peak_memory_table])
    return


@app.cell
def _(mo):
    mo.image("./plots/fib_peak_memory_vs_n.png", height=500, width=700, rounded=True)
    return


if __name__ == "__main__":
    app.run()
