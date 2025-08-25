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

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))

DATA_DIR = os.path.join(
    CURRENT_DIR,
    os.path.pardir,
    os.path.pardir,
    "benchmarks-ir",
    "gromacs-gpu",
)

STEPS = {"TestcaseA_benchmarks": "steps_20000", "TestcaseB_benchmarks": "steps_1000"}


def extract_values(md_log_path):
    wall_time, performance, io_time = None, None, None
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
                if "Write traj." in lines[i]:
                    io_time = lines[i].split()[5]
                if wall_time and performance and io_time:
                    break
    except Exception as e:
        print(f"Error reading {md_log_path}: {e}")
    if wall_time is None or performance is None or io_time is None:
        print(f"Missing data in {md_log_path}")
        raise RuntimeError()
    return wall_time, performance, io_time


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
    return len(data), mean_value, error


def process_benchmarks(base_dir):
    results = {}
    devices = ["ault23", "ault25"]

    device_cases = {
        "ault23": ["specialized", "CUDA_AVX_512"],
        "ault25": ["specialized", "CUDA_AVX2_256"],
    }

    for device in devices:
        device_path = os.path.join(base_dir, device, "gromacs-benchmarks")
        if not os.path.isdir(device_path):
            print(f"Device directory {device_path} not found, skipping...")
            continue

        results[device] = {}

        for testcase in ["TestcaseA_benchmarks", "TestcaseB_benchmarks"]:
            testcase_path = os.path.join(device_path, testcase)
            if not os.path.isdir(testcase_path):
                print(f"Testcase directory {testcase_path} not found, skipping...")
                continue

            testcase_letter = testcase.split("_")[0][-1]  # Gets 'A' or 'B'

            for case in device_cases[device]:
                # Directory name format: gromacs_{case}_testcase{A/B}
                case_dir_name = f"gromacs_{case}_testcase{testcase_letter}"
                case_path = os.path.join(testcase_path, case_dir_name)

                if not os.path.isdir(case_path):
                    print(f"Case directory {case_path} not found, skipping...")
                    continue

                if case not in results[device]:
                    results[device][case] = {}

                wall_times, performances, io_times = [], [], []

                steps_path = os.path.join(case_path, STEPS[testcase])
                if not os.path.isdir(steps_path):
                    print(f"Steps directory {steps_path} not found, skipping...")
                    continue

                for run in range(3, 33):
                    log_path = os.path.join(steps_path, f"run{run}", "md.log")
                    if os.path.exists(log_path):
                        try:
                            wall, perf, io_time = extract_values(log_path)
                            if wall and perf:
                                wall_times.append(wall)
                                performances.append(perf)
                                io_times.append(io_time)
                        except RuntimeError:
                            continue

                if wall_times and performances:
                    execution_times = []
                    io_times_float = []

                    for i in range(len(wall_times)):
                        io_time_val = float(io_times[i])
                        execution_times.append(wall_times[i] - io_time_val)
                        io_times_float.append(io_time_val)

                    exec_samples, exec_mean, exec_ci = compute_statistics(
                        execution_times, harmonic=False
                    )
                    _, io_mean, io_ci = compute_statistics(
                        io_times_float, harmonic=False
                    )
                    _, perf_mean, perf_ci = compute_statistics(
                        performances, harmonic=True
                    )

                    results[device][case][testcase] = {
                        "execution_time": (exec_mean, exec_ci),
                        "io_time": (io_mean, io_ci),
                        "performance": (perf_mean, perf_ci),
                    }

                    total_time = exec_mean + io_mean
                    print(
                        f"{device}-{case}-{testcase} → Samples {exec_samples} Execution Time: {exec_mean:.2f} ± {exec_ci:.2f} s | I/O Time: {io_mean:.2f} ± {io_ci:.2f} s | Total: {total_time:.2f} s | Performance: {perf_mean:.2f} ± {perf_ci:.2f} ns/day"
                    )

    return results


def plot_grouped_dual_axis(results):
    """Create horizontal bar plots side by side for each device"""

    plt.style.use("ggplot")
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 2.5), dpi=100)

    devices = ["ault23", "ault25"]
    axes = [ax1, ax2]
    testcases = ["TestcaseA_benchmarks", "TestcaseB_benchmarks"]

    colors = {
        "TestcaseA_benchmarks": "#3498db",
        "TestcaseB_benchmarks": "#E74C3C",
        "io": "#95A5A6",
    }

    bar_height = 0.05
    testcase_spacing = 0.02

    from matplotlib.patches import Patch

    legend_elements = [
        Patch(facecolor=colors["TestcaseA_benchmarks"], label="Test A"),
        Patch(facecolor=colors["TestcaseB_benchmarks"], label="Test B"),
        Patch(facecolor=colors["io"], label="I/O Time", hatch="///"),
    ]

    for device, ax in zip(devices, axes):
        bar_positions = []
        bar_labels = []
        bar_label_positions = []
        y_pos = 0

        config_types = [
            ("specialized", "Docker"),
            ("CUDA_AVX_512" if device == "ault23" else "CUDA_AVX2_256", "XaaS IR"),
        ]

        for config_key, config_name in config_types:
            bar_label_positions.append(y_pos)
            for testcase in testcases:
                bar_positions.append(y_pos)

                y_pos += bar_height + 0.01

            bar_labels.append(f"{config_name}")
            y_pos += testcase_spacing

        bar_separator_pos = bar_positions[1] + bar_height - testcase_spacing / 2

        # CUDA needs to be a little lower
        bar_label_positions[1] -= 0.02
        bar_label_positions[0] -= 0.02

        bar_index = 0

        for config_key, config_name in config_types:
            for testcase in testcases:
                if (
                    config_key in results[device]
                    and testcase in results[device][config_key]
                ):
                    exec_time, exec_error = results[device][config_key][testcase][
                        "execution_time"
                    ]
                    io_time, io_error = results[device][config_key][testcase]["io_time"]

                    exec_color = colors[testcase]

                    ax.barh(
                        bar_positions[bar_index],
                        exec_time,
                        bar_height,
                        color=exec_color,
                        alpha=0.8,
                        edgecolor="black",
                        linewidth=0.8,
                    )

                    ax.barh(
                        bar_positions[bar_index],
                        io_time,
                        bar_height,
                        left=exec_time,
                        color=colors["io"],
                        alpha=0.8,
                        hatch="///",
                        edgecolor="black",
                        linewidth=0.8,
                    )

                    total_time = exec_time + io_time
                    ax.text(
                        total_time + total_time * 0.01,
                        bar_positions[bar_index],
                        f"{total_time:.1f}",
                        ha="left",
                        va="center",
                        fontsize=12,
                    )

                bar_index += 1

        ax.axhline(
            y=bar_separator_pos, color="gray", linestyle="--", linewidth=1.5, alpha=0.7
        )

        ax.set_xlabel(
            "Execution Time (s)",
            fontsize=14,
            fontweight="bold",
            # horizontalalignment="right" if device == "ault23" else "left",
        )
        # ax.set_title(
        #    f"GROMACS GPU, {device.capitalize()}",
        #    fontsize=12, fontweight="bold"
        # )

        ax.set_yticks(bar_label_positions)
        ax.set_yticklabels(bar_labels, fontsize=13, rotation=90, fontweight="bold")
        ax.tick_params(axis="y", length=0)
        ax.tick_params(axis="x", labelsize=12)

        ax.grid(True, linestyle="--", alpha=0.3, axis="y")

        ax.invert_yaxis()

    fig.legend(
        handles=legend_elements,
        loc="upper center",
        bbox_to_anchor=(0.5, 0.0),
        ncol=3,
        fontsize=15,
        frameon=False,
    )

    fig.suptitle(
        "V100 (left) and A100 (right), Test A (20,000 steps) and B (1,000 steps)",
        fontsize=16,
        fontweight="bold",
    )

    plt.tight_layout()
    # plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.subplots_adjust(top=0.8, bottom=0.15, wspace=0.11)

    return fig


results = process_benchmarks(DATA_DIR)
fig = plot_grouped_dual_axis(results)
if fig:
    output_path = os.path.join(CURRENT_DIR, "ir_gpu_comparison.pdf")
    fig.savefig(output_path, format="pdf", dpi=300, bbox_inches="tight")
    print(f"Plot saved to: {output_path}")
