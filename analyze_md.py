import os
import pandas as pd
import matplotlib.pyplot as plt
import itertools
import numpy as np
from jinja2 import Environment, FileSystemLoader
from tabulate import tabulate

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
        "openvm": f'./benchmark_outputs/openvm-{bench_name}.csv',
        "r0": f'./benchmark_outputs/risczero-{bench_name}.csv',
        "stone": f'./benchmark_outputs/stone-{bench_name}.csv',
        "stwo": f'./benchmark_outputs/stwo-{bench_name}.csv',
    }

    if is_precompile:
        file_paths["sp1-precompile"] = f'./benchmark_outputs/sp1-{bench_name}-precompile.csv'
        file_paths["r0-precompile"] = f'./benchmark_outputs/risczero-{bench_name}-precompile.csv'
        file_paths["openvm-precompile"] = f'./benchmark_outputs/openvm-{bench_name}-precompile.csv'

    if bench_name == 'sha3-chain' and is_builtin:
        file_paths.pop("stone", None)

    combined_df = None

    for name, path in file_paths.items():
        df = preprocess_data(pd.read_csv(path), column_name)

        df.rename(columns={column_name: name}, inplace=True)

        if combined_df is None:
            combined_df = df
        else:
            combined_df = pd.merge(combined_df, df, on="n", how="outer")

    return combined_df


def plot_benchmark(df, title, y_label, bench_tuple, column_name):
    """Plot the benchmark data with fixed color and marker mapping per column."""
    bench_name, _, is_builtin = bench_tuple

    style_map = {
        'jolt': ('o', 'b'),
        'r0': ('s', 'r'),
        'sp1': ('D', 'g'),
        'stone': ('^', 'm'),
        'stwo': ('v', 'c'),
        'r0-precompile': ('*', 'y'),
        'sp1-precompile': ('P', 'k'),
        'stone-builtin': ('h', '#8B0000'),
        'openvm': ('X', '#FF7F0E'),
        'openvm-precompile': ('d', '#2CA02C'),
    }

    plt.figure(figsize=(8, 6))

    for col in df.columns[1:]:
        if col in style_map:
            marker, color = style_map[col]
        else:
            marker, color = ('x', 'gray')

        non_zero = df[col] != 0
        plt.plot(df["n"][non_zero], df[col][non_zero], 
                    marker=marker, color=color, label=col, linestyle='-')

    if bench_name == 'sha3' and is_builtin:
        path = f'./benchmark_outputs/stone-{bench_name}-builtin.csv'
        stone_df = preprocess_data(pd.read_csv(path), column_name)
        stone_df["n"] *= 200
        marker, color = style_map["stone-builtin"]
        plt.plot(stone_df["n"], stone_df[column_name], marker=marker, color=color,
                    label="stone-builtin", linestyle='-')

    if bench_name == 'sha3-chain' and is_builtin:
        path = f'./benchmark_outputs/stone-{bench_name}-builtin.csv'
        stone_df = preprocess_data(pd.read_csv(path), column_name)
        stone_df["n"] = np.ceil(stone_df["n"] * (200 / 32))
        marker, color = style_map["stone-builtin"]
        plt.plot(stone_df["n"], stone_df[column_name], marker=marker, color=color,
                    label="stone-builtin", linestyle='-')

    plt.xlabel("n")
    plt.ylabel(y_label)
    plt.title(title)
    plt.yscale("log")
    plt.xscale("log")
    plt.legend()
    plt.grid(True, which="both", linestyle="--", linewidth=0.5)

    plt.xticks(df["n"], df["n"], rotation=45)

    # Save the plot
    filename = f"./plots/{bench_name}_{title.replace(' ', '_').lower()}.png"
    plt.savefig(filename, dpi=300)
    plt.close()

    return filename


def get_data(bench_tuple):
    prover_time_df = combine_benchmark(bench_tuple, "prover time(ms)")
    verifier_time_df = combine_benchmark(bench_tuple, "verifier time(ms)")
    proof_size_df = combine_benchmark(bench_tuple, "proof size(bytes)")
    cycle_count_df = combine_benchmark(bench_tuple, "cycle count")
    cycle_count_df = cycle_count_df.drop(columns=['openvm', 'openvm-precompile'], errors='ignore')
    peak_memory_df = combine_benchmark(bench_tuple, "peak memory")
    return prover_time_df, verifier_time_df, proof_size_df, cycle_count_df, peak_memory_df

def get_tables(bench_tuple):
    prover_time_df, verifier_time_df, proof_size_df, cycle_count_df, peak_memory_df = get_data(bench_tuple)

    # Assuming your DataFrames may have NaN or empty strings
    dataframes = [prover_time_df, verifier_time_df, proof_size_df, cycle_count_df, peak_memory_df]

    # Replace NaN or empty strings with "*"
    dataframes = [df.astype(str).replace({"nan": "*", "NaN": "*", "": "*"}) for df in dataframes]


    # Unpack back to original variables if needed
    prover_time_df, verifier_time_df, proof_size_df, cycle_count_df, peak_memory_df = dataframes

    tables = {
        "prover_time": tabulate(prover_time_df.values.tolist(), headers=prover_time_df.columns, tablefmt="github"),
        "verifier_time": tabulate(verifier_time_df.values.tolist(), headers=verifier_time_df.columns, tablefmt="github"),
        "proof_size": tabulate(proof_size_df.values.tolist(), headers=proof_size_df.columns, tablefmt="github"),
        "cycle_count": tabulate(cycle_count_df.values.tolist(), headers=cycle_count_df.columns, tablefmt="github"),
        "peak_memory": tabulate(peak_memory_df.values.tolist(), headers=peak_memory_df.columns, tablefmt="github"),
    }

    return tables

def get_plots(bench_tuple):
    prover_time_df, verifier_time_df, proof_size_df, cycle_count_df, peak_memory_df = get_data(bench_tuple)
    prover_time_plot = plot_benchmark(prover_time_df, "Prover Time vs n", "Prover Time (s)", bench_tuple, "prover time(ms)")
    verifier_time_plot = plot_benchmark(verifier_time_df, "Verifier Time vs n", "Verifier Time (ms)", bench_tuple, "verifier time(ms)")
    proof_size_plot = plot_benchmark(proof_size_df, "Proof Size vs n", "Proof Size (KB)", bench_tuple, "proof size(bytes)")
    cycle_count_plot = plot_benchmark(cycle_count_df, "Cycle Count vs n", "Cycle Count", bench_tuple, "cycle count")
    peak_memory_plot = plot_benchmark(peak_memory_df, "Peak Memory vs n", "Peak Memory", bench_tuple, "peak memory")

    plots = {
        "prover_time_plot": prover_time_plot,
        "verifier_time_plot": verifier_time_plot,
        "proof_size_plot": proof_size_plot,
        "cycle_count_plot": cycle_count_plot,
        "peak_memory_plot": peak_memory_plot,
    }

    return plots

# Commit Info
commit_file = "./report_info/latest_commit.txt"
with open(commit_file, "r") as file1:
    commit_hash = file1.readline().strip()

# Timestamp Info
time_file = "./report_info/time_stamp.txt"
with open(time_file, "r") as file1:
    time = file1.readline().strip()


# OS Info
os_version_file = "./report_info/os_version.txt"
os_version = "Unknown"
with open(os_version_file, "r") as file:
    for line in file:
        if line.startswith("PRETTY_NAME="):
            os_version = line.split("=", 1)[1].strip().strip('"')
            break

# CPU Info
cpuinfo_file = "./report_info/cpuinfo.txt"
cpu_keys = [
    "Architecture",
    "CPU(s)",
    "Model name",
    "Thread(s) per core",
    "Core(s) per socket",
    "Socket(s)",
    "L3 cache"
]

cpu_info = {}

with open(cpuinfo_file, "r") as file:
    for line in file:
        for key in cpu_keys:
            if line.startswith(key):
                value = line.split(":", 1)[1].strip()
                cpu_info[key] = value

# Memory Info
meminfo_file = "./report_info/meminfo.txt"
mem_keys = [
    "MemTotal",
    "MemFree",
    "MemAvailable",
    "Buffers",
    "Cached",
    "SwapTotal",
    "SwapFree"
]

mem_info = {}

with open(meminfo_file, "r") as file:
    for line in file:
        key_value = line.split(":", 1)
        if len(key_value) == 2:
            key, value = key_value[0].strip(), key_value[1].strip()
            if key in mem_keys:
                mem_info[key] = value


# Fibonacci
fib_tuple = ("fib", False, False)
fib_tables = get_tables(fib_tuple)
fib_plots = get_plots(fib_tuple)
fib_data = {"tables": fib_tables, "plots": fib_plots}

# Sha2
sha2_tuple = ("sha2", True, False)
sha2_tables = get_tables(sha2_tuple)
sha2_plots = get_plots(sha2_tuple)
sha2_data = {"tables": sha2_tables, "plots": sha2_plots}

# Sha2-chain
sha2_chain_tuple = ("sha2-chain", True, False)
sha2_chain_tables = get_tables(sha2_chain_tuple)
sha2_chain_plots = get_plots(sha2_chain_tuple)
sha2_chain_data = {"tables": sha2_chain_tables, "plots": sha2_chain_plots}

# Sha3
sha3_tuple = ("sha3", True, True)
sha3_tables = get_tables(sha3_tuple)
sha3_plots = get_plots(sha3_tuple)
sha3_data = {"tables": sha3_tables, "plots": sha3_plots}

path = f'./benchmark_outputs/stone-sha3-builtin.csv'
stone_sha3_builtin_df = pd.read_csv(path)
stone_sha3_builtin_df["n"] *= 200
stone_sha3_builtin_table = tabulate(stone_sha3_builtin_df.values.tolist(), headers=stone_sha3_builtin_df.columns, tablefmt="github")

# Sha3-chain
sha3_chain_tuple = ("sha3-chain", True, True)
sha3_chain_tables = get_tables(sha3_chain_tuple)
sha3_chain_plots = get_plots(sha3_chain_tuple)
sha3_chain_data = {"tables": sha3_chain_tables, "plots": sha3_chain_plots}

path_chain = f'./benchmark_outputs/stone-sha3-chain-builtin.csv'
stone_sha3_chain_builtin_df = pd.read_csv(path_chain)
stone_sha3_chain_builtin_table = tabulate(stone_sha3_chain_builtin_df.values.tolist(), headers=stone_sha3_chain_builtin_df.columns, tablefmt="github")

# Mat Mul
mat_mul_tuple = ("mat-mul", False, False)
mat_mul_tables = get_tables(mat_mul_tuple)
mat_mul_plots = get_plots(mat_mul_tuple)
mat_mul_data = {"tables": mat_mul_tables, "plots": mat_mul_plots}

# Load template
env = Environment(loader=FileSystemLoader("."))
template = env.get_template("template.md.j2")

# Render Markdown
output_md = template.render(
    commit_hash=commit_hash,
    time=time,
    os_version=os_version,
    cpu_info=cpu_info,
    mem_info=mem_info,
    fib_data=fib_data,
    sha2_data=sha2_data,
    sha2_chain_data=sha2_chain_data,
    sha3_data=sha3_data,
    stone_sha3_builtin_table=stone_sha3_builtin_table,
    sha3_chain_data=sha3_chain_data,
    stone_sha3_chain_builtin_table=stone_sha3_chain_builtin_table,
    mat_mul_data=mat_mul_data,
)

# Save to index.md
with open("index.md", "w") as f:
    f.write(output_md)

print("index.md generated.")