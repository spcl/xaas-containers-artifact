import os
import re
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
import argparse

from matplotlib.patches import FancyArrowPatch

import matplotlib

matplotlib.rcParams["pdf.fonttype"] = 42
matplotlib.rcParams["ps.fonttype"] = 42

X86_VECTORIZATIONS = {
    "x86-Default",
    "x86-SSE2",
    "x86-SSE4.1",
    "x86-AVX_128_FMA",
    "x86-AVX_256",
    "x86-AVX2_128",
    "x86-AVX2_256",
    "x86-AVX_512",
}
ARM_VECTORIZATIONS = {"arm-Default", "arm-NEON_ASIMD", "arm-SVE"}

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))

DATA_DIR = os.path.join(
    CURRENT_DIR,
    os.path.pardir,
    os.path.pardir,
    "hpc-benchmarks",
    "gromacs-cpu",
    "ault01",
    "gromacs-benchmarks",
)


def extract_values(md_log_path):
    wall_time, performance = None, None
    try:
        with open(md_log_path, "r") as file:
            lines = file.readlines()
            for i in range(len(lines)):
                if "Time:" in lines[i]:
                    time_values = re.findall(r"\d+\.\d+", lines[i])
                    if len(time_values) >= 2:
                        wall_time = float(time_values[1])
                if "Performance:" in lines[i]:
                    perf_values = re.findall(r"\d+\.\d+", lines[i])
                    if perf_values:
                        performance = float(perf_values[0])
                if wall_time and performance:
                    break
    except Exception as e:
        print(f"Error reading {md_log_path}: {e}")
    return wall_time, performance


def compute_statistics(data, harmonic=False):
    if not data:
        return None, None
    mean_value = stats.hmean(data) if harmonic else np.mean(data)
    confidence = (
        stats.t.interval(0.95, len(data) - 1, loc=mean_value, scale=stats.sem(data))
        if len(data) > 1
        else (mean_value, mean_value)
    )
    error = (confidence[1] - confidence[0]) / 2 if len(data) > 1 else 0
    return mean_value, error


def process_benchmarks(base_dir):
    results = {}
    for arch in ["TestcaseA_benchmarks", "TestcaseB_benchmarks"]:
        print(base_dir)
        arch_path = os.path.join(base_dir, arch)
        if not os.path.isdir(arch_path):
            continue

        for vec_flag in os.listdir(arch_path):
            vec_path = os.path.join(arch_path, vec_flag)
            if not os.path.isdir(vec_path):
                continue

            wall_times, performances = [], []

            for run in range(11, 41):
                log_path = os.path.join(vec_path, f"run{run}", "md.log")
                if os.path.exists(log_path):
                    wall, perf = extract_values(log_path)
                    if wall and perf:
                        wall_times.append(wall)
                        performances.append(perf)

            if wall_times and performances:
                wall_mean, wall_ci = compute_statistics(wall_times, harmonic=False)
                perf_mean, perf_ci = compute_statistics(performances, harmonic=True)

                # Change "intel" to "x86" in label
                label = f"x86-{vec_flag}" if arch == "intel" else f"{arch}-{vec_flag}"
                results[label] = {
                    "wall_time": (wall_mean, wall_ci),
                    "performance": (perf_mean, perf_ci),
                }

                arch_display = "x86" if arch == "intel" else arch
                print(
                    f"{arch_display}-{vec_flag} → Execution Time: {wall_mean:.2f} ± {wall_ci:.2f} s | Performance: {perf_mean:.2f} ± {perf_ci:.2f} ns/day"
                )

    return results


def plot_side_by_side_execution_times(results):
    print(results)
    x86_results = {k: v for k, v in results.items() if k.startswith("TestcaseA_")}
    arm_results = {k: v for k, v in results.items() if k.startswith("TestcaseB_")}
    print(x86_results)

    x86_sorted = sorted(
        x86_results.items(), key=lambda x: x[1]["wall_time"][0], reverse=True
    )
    arm_sorted = sorted(
        arm_results.items(), key=lambda x: x[1]["wall_time"][0], reverse=True
    )

    x86_labels = [item[0].split("-", 1)[1] for item in x86_sorted]
    x86_means = [item[1]["wall_time"][0] for item in x86_sorted]
    x86_errors = [item[1]["wall_time"][1] for item in x86_sorted]

    arm_labels = [item[0].split("-", 1)[1] for item in arm_sorted]
    arm_means = [item[1]["wall_time"][0] for item in arm_sorted]
    arm_errors = [item[1]["wall_time"][1] for item in arm_sorted]

    plt.style.use("ggplot")
    # fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6), dpi=100)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4), dpi=100)

    x86_color = "#3498db"  # Blue shade
    arm_color = "#e74c3c"  # Red shade

    bars1 = ax1.bar(
        x86_labels,
        x86_means,
        yerr=x86_errors,
        capsize=4,
        alpha=0.8,
        color=x86_color,
        edgecolor="black",
        linewidth=0.8,
    )
    ax1.set_title(
        "TestCase A, 1 core",
        fontsize=18,
        fontweight="bold",
        pad=15,
    )
    ax1.set_ylabel("Execution Time (s)", fontsize=18, fontweight="bold")
    # ax1.set_xlabel("Vectorization Type", fontsize=18, fontweight="bold")
    ax1.tick_params(axis="x", rotation=30, labelsize=18)
    ax1.tick_params(axis="y", labelsize=18)
    ax1.grid(True, linestyle="--", alpha=0.7)

    current_xticks_text = ax1.get_xticklabels()

    # Extract the text from the Text objects
    current_xticks_labels = [label.get_text() for label in current_xticks_text]

    transformed_labels = []
    prefix = "gromacs_"
    suffix = "_testcaseB"

    for label in current_xticks_labels:
        if label.startswith(prefix) and label.endswith(suffix):
            # Extract the part between the prefix and suffix
            val = label[len(prefix) : -len(suffix)]
            if val == "portable":
                val = "Portable"
            transformed_labels.append(val)
        else:
            # Handle cases where the label doesn't match the expected pattern
            transformed_labels.append(label)  # Keep the original label

    # Transform the labels to extract the 'val' part
    # transformed_labels = [label.split("_")[1] for label in current_xticks_labels]
    ax1.set_xticklabels(transformed_labels)

    for bar in bars1:
        height = bar.get_height()
        ax1.text(
            bar.get_x() + bar.get_width() / 2.0,
            height + 0.7,
            f"{height:.1f}s",
            ha="center",
            va="bottom",
            fontsize=18,
        )

    bars2 = ax2.bar(
        arm_labels,
        arm_means,
        yerr=arm_errors,
        capsize=4,
        alpha=0.8,
        color=arm_color,
        edgecolor="black",
        linewidth=0.8,
    )
    ax2.set_title(
        "TestCase B, 36 cores",
        fontsize=18,
        fontweight="bold",
        pad=15,
    )
    ax2.set_ylabel("Execution Time (s)", fontsize=18, fontweight="bold")
    # ax2.set_xlabel("Vectorization Type", fontsize=18, fontweight="bold")
    ax2.tick_params(axis="x", rotation=30, labelsize=18)
    ax2.tick_params(axis="y", labelsize=18)
    ax2.grid(True, linestyle="--", alpha=0.7)

    current_xticks_text = ax2.get_xticklabels()

    # Extract the text from the Text objects
    current_xticks_labels = [label.get_text() for label in current_xticks_text]

    transformed_labels = []
    prefix = "gromacs_"
    suffix = "_testcaseB"

    for label in current_xticks_labels:
        if label.startswith(prefix) and label.endswith(suffix):
            # Extract the part between the prefix and suffix
            val = label[len(prefix) : -len(suffix)]
            if val == "portable":
                val = "Portable"
            transformed_labels.append(val)
        else:
            # Handle cases where the label doesn't match the expected pattern
            transformed_labels.append(label)  # Keep the original label

    # Transform the labels to extract the 'val' part
    # transformed_labels = [label.split("_")[1] for label in current_xticks_labels]
    ax2.set_xticklabels(transformed_labels)
    # Add values above bars
    for bar in bars2:
        height = bar.get_height()
        ax2.text(
            bar.get_x() + bar.get_width() / 2.0,
            height + 2,
            f"{height:.1f}s",
            ha="center",
            va="bottom",
            fontsize=18,
        )

    # Ensure the same y-axis range for better comparison
    # max_y = max(max(x86_means), max(arm_means)) * 1.2
    # ax1.set_ylim(0, max_y)
    # ax2.set_ylim(0, max_y)

    plt.tight_layout(rect=[0, 0, 1, 0.95])

    return fig


def main():
    parser = argparse.ArgumentParser(
        description="Benchmark different vectorization flags from x86 and ARM builds."
    )
    parser.add_argument(
        "input_directory",
        type=str,
        help="Path to the top-level directory (with intel/ and arm/)",
    )

    results = process_benchmarks(DATA_DIR)
    if not results:
        print("No data found.")
        return

    fig = plot_side_by_side_execution_times(results)
    if fig:
        output_path = os.path.join(CURRENT_DIR, "vectorization_comparison.pdf")
        fig.savefig(output_path, format="pdf", dpi=300, bbox_inches="tight")
        print(f"Plot saved to: {output_path}")


if __name__ == "__main__":
    main()
