import os
import re
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
import argparse

INTEL_VECTORIZATIONS = {"intel-None", "intel-SSE2", "intel-SSE4.1", "intel-AVX_128_FMA", "intel-AVX_256", "intel-AVX2_128", "intel-AVX2_256", "intel-AVX_512"}
ARM_VECTORIZATIONS = {"arm-None", "arm-NEON_ASIMD", "arm-SVE"}

def extract_values(md_log_path):
    wall_time, performance = None, None
    try:
        with open(md_log_path, 'r') as file:
            lines = file.readlines()
            for i in range(len(lines)):
                if "Time:" in lines[i]:
                    time_values = re.findall(r'\d+\.\d+', lines[i])
                    if len(time_values) >= 2:
                        wall_time = float(time_values[1])
                if "Performance:" in lines[i]:
                    perf_values = re.findall(r'\d+\.\d+', lines[i])
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
    confidence = stats.t.interval(0.95, len(data)-1, loc=mean_value, scale=stats.sem(data)) if len(data) > 1 else (mean_value, mean_value)
    error = (confidence[1] - confidence[0]) / 2 if len(data) > 1 else 0
    return mean_value, error

def process_benchmarks(base_dir):
    results = {}
    for arch in ["intel", "arm"]:
        arch_path = os.path.join(base_dir, arch)
        if not os.path.isdir(arch_path):
            continue

        for vec_flag in os.listdir(arch_path):
            vec_path = os.path.join(arch_path, vec_flag)
            if not os.path.isdir(vec_path):
                continue

            wall_times, performances = [], []

            for run in range(11, 41):
                log_path = os.path.join(vec_path, f'run{run}', 'md.log')
                if os.path.exists(log_path):
                    wall, perf = extract_values(log_path)
                    if wall and perf:
                        wall_times.append(wall)
                        performances.append(perf)

            if wall_times and performances:
                wall_mean, wall_ci = compute_statistics(wall_times, harmonic=False)
                perf_mean, perf_ci = compute_statistics(performances, harmonic=True)
                label = f"{arch}-{vec_flag}"
                results[label] = {
                    "wall_time": (wall_mean, wall_ci),
                    "performance": (perf_mean, perf_ci)
                }

                print(f"{label} → Execution Time: {wall_mean:.2f} ± {wall_ci:.2f} s | Performance: {perf_mean:.2f} ± {perf_ci:.2f} ns/day")

    return results

def plot_vectorization_results(results, title_prefix, filter_set):
    filtered = {k: v for k, v in results.items() if k in filter_set}
    if not filtered:
        return

    sorted_items = sorted(filtered.items(), key=lambda x: x[1]['performance'][0])
    labels = [item[0].split('-', 1)[1] for item in sorted_items]  # remove 'intel-' or 'arm-' prefix for display
    wall_means = [item[1]["wall_time"][0] for item in sorted_items]
    wall_errors = [item[1]["wall_time"][1] for item in sorted_items]
    perf_means = [item[1]["performance"][0] for item in sorted_items]
    perf_errors = [item[1]["performance"][1] for item in sorted_items]

    fig, axs = plt.subplots(1, 2, figsize=(18, 7), constrained_layout=True)

    axs[0].bar(labels, wall_means, yerr=wall_errors, capsize=5, alpha=0.7)
    axs[0].set_title(f"{title_prefix} Execution Time", fontweight='bold')
    axs[0].set_ylabel("Execution Time (s)")
    axs[0].set_xlabel("Vectorization")
    axs[0].tick_params(axis='x', rotation=45)

    axs[1].bar(labels, perf_means, yerr=perf_errors, capsize=5, alpha=0.7)
    axs[1].set_title(f"{title_prefix} Performance", fontweight='bold')
    axs[1].set_ylabel("Performance (ns/day)")
    axs[1].set_xlabel("Vectorization")
    axs[1].tick_params(axis='x', rotation=45)

    plt.show()

def main():
    parser = argparse.ArgumentParser(description="Benchmark different vectorization flags from Intel and ARM builds.")
    parser.add_argument("input_directory", type=str, help="Path to the top-level directory (with intel/ and arm/)")
    args = parser.parse_args()

    results = process_benchmarks(args.input_directory)
    if not results:
        print("No data found.")
        return

    print("\n=== Intel Vectorizations ===")
    plot_vectorization_results(results, "Intel Vectorization", INTEL_VECTORIZATIONS)

    print("\n=== ARM Vectorizations ===")
    plot_vectorization_results(results, "ARM Vectorization", ARM_VECTORIZATIONS)

if __name__ == "__main__":
    main()