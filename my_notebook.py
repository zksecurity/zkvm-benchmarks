import marimo

__generated_with = "0.11.5"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo

    mo.md("# zkvm benchmarks")
    return (mo,)


@app.cell
def _(mo):
    mo.md("## Machine Specification")
    return


@app.cell
def _(mo):
    mo.md("hello")

    # Importing necessary libraries
    from pathlib import Path

    # Define the folder containing your .txt files
    txt_folder = Path("./benchmark-results/machine_info/")

    # # Check if the folder exists
    # if not txt_folder.exists():
    #     print("The folder containing .txt files does not exist. Please ensure the path is correct.")
    # else:
    #     # Iterate through all .txt files in the folder
    #     txt_files = list(txt_folder.glob("*.txt"))

    #     if not txt_files:
    #         print("No .txt files found in the specified folder.")
    #     else:
    #         for txt_file in txt_files:
    #             # Read the content of the file
    #             with txt_file.open("r") as file:
    #                 content = str(file.read())
    #                 t = "hello"

    #             # Display the file name and its content
    #             # print(f"\n{'='*40}\nFile: {txt_file.name}\n{'='*40}")
    #             # print(f"{content}\n")
    #             mo.md(f"{content}\n")
    #             mo.md(f"{t}\n")
                
    return Path, txt_folder


if __name__ == "__main__":
    app.run()
