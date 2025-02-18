import pandas as pd
import matplotlib.pyplot as plt

# Function to preprocess the dataframes
def preprocess_data(df):
    # Drop rows with missing values in relevant columns
    df = df.dropna(subset=["n", "prover time(ms)", "proof size(bytes)", "verifier time(ms)"])
    # Ensure 'n' is sorted
    df = df.sort_values(by="n").reset_index(drop=True)
    return df

# Function to plot the metrics and save the plots
def plot_metrics(bench_name):
    jolt_file_name = 'jolt-' + bench_name + '.csv'
    sp1_file_name = 'sp1-' + bench_name + '.csv'
    r0_file_name = 'risczero-' + bench_name + '.csv'
    stone_file_name = 'stone-' + bench_name + '.csv'

    # Read the CSV files
    jolt_df = preprocess_data(pd.read_csv(jolt_file_name))
    sp1_df = preprocess_data(pd.read_csv(sp1_file_name))
    r0_df = preprocess_data(pd.read_csv(r0_file_name))
    stone_df = preprocess_data(pd.read_csv(stone_file_name))

    # Convert columns
    for df in [jolt_df, sp1_df, r0_df, stone_df]:
        df["prover time (s)"] = df["prover time(ms)"] / 1000  # ms to s
        df["proof size (MB)"] = df["proof size(bytes)"] / (1024 * 1024)  # bytes to MB

    # Plot Prover Time
    plt.figure(figsize=(10, 6))
    plt.plot(jolt_df["n"], jolt_df["prover time (s)"], label="Jolt", marker='o', linestyle='--')
    plt.plot(sp1_df["n"], sp1_df["prover time (s)"], label="SP1", marker='o', linestyle='--')
    plt.plot(r0_df["n"], r0_df["prover time (s)"], label="R0", marker='o', linestyle='--')
    plt.plot(stone_df["n"], stone_df["prover time (s)"], label="Stone", marker='o', linestyle='--')
    plt.xlabel("n", fontsize=12)
    plt.ylabel("Prover Time (s)", fontsize=12)
    plt.title("Prover Time vs n", fontsize=14)
    plt.legend()
    plt.grid(True, linestyle="--", alpha=0.6)
    plt.tight_layout()
    plt.savefig(f"{bench_name}_prover_time.png", dpi=300)
    plt.close()

    # Plot Proof Size
    plt.figure(figsize=(10, 6))
    plt.plot(jolt_df["n"], jolt_df["proof size (MB)"], label="Jolt", marker='o', linestyle='--')
    plt.plot(sp1_df["n"], sp1_df["proof size (MB)"], label="SP1", marker='o', linestyle='--')
    plt.plot(r0_df["n"], r0_df["proof size (MB)"], label="R0", marker='o', linestyle='--')
    plt.plot(stone_df["n"], stone_df["proof size (MB)"], label="Stone", marker='o', linestyle='--')
    plt.xlabel("n", fontsize=12)
    plt.ylabel("Proof Size (MB)", fontsize=12)
    plt.title("Proof Size vs n", fontsize=14)
    plt.legend()
    plt.grid(True, linestyle="--", alpha=0.6)
    plt.tight_layout()
    plt.savefig(f"{bench_name}_proof_size.png", dpi=300)
    plt.close()

    # Plot Verifier Time
    plt.figure(figsize=(10, 6))
    plt.plot(jolt_df["n"], jolt_df["verifier time(ms)"], label="Jolt", marker='o', linestyle='--')
    plt.plot(sp1_df["n"], sp1_df["verifier time(ms)"], label="SP1", marker='o', linestyle='--')
    plt.plot(r0_df["n"], r0_df["verifier time(ms)"], label="R0", marker='o', linestyle='--')
    plt.plot(stone_df["n"], stone_df["verifier time(ms)"], label="Stone", marker='o', linestyle='--')
    plt.xlabel("n", fontsize=12)
    plt.ylabel("Verifier Time (ms)", fontsize=12)
    plt.title("Verifier Time vs n", fontsize=14)
    plt.legend()
    plt.grid(True, linestyle="--", alpha=0.6)
    plt.tight_layout()
    plt.savefig(f"{bench_name}_verifier_time.png", dpi=300)
    plt.close()

    print("Plots saved successfully!")

# Example usage
bench_name = "fib"
plot_metrics(bench_name)
