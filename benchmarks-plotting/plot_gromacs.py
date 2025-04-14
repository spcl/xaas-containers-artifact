import os
import re
import numpy as np
import scipy.stats as stats
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import argparse

# Use seaborn styling
sns.set_style("darkgrid", {"grid.color": ".6", "grid.linestyle": ":"})

colors = {
    "native": "#6B6463",
    "naive": "#237CCC",
    "spack": "#FFD62B",
    "optimized_spack": "#5415F2",
    "xaas": "#E10909",
    "specialized": "#067114",
}

legends = {
    "native": "Native build",
    "naive": "Naive build",
    "spack": "Spack build",
    "optimized_spack": "Spack optimized",
    "xaas": "XaaS source container",
    "specialized": "Specialized build",
}

def extract_values(md_log_path):
    wall_time, performance = None, None
    try:
        with open(md_log_path, 'r') as file:
            for line in file:
                if "Time:" in line:
                    time_values = re.findall(r'\d+\.\d+', line)
                    if len(time_values) >= 2:
                        wall_time = float(time_values[1])
                if "Performance:" in line:
                    perf_values = re.findall(r'\d+\.\d+', line)
                    if perf_values:
                        performance = float(perf_values[0])
                if wall_time is not None and performance is not None:
                    break
    except Exception as e:
        print(f"Error reading {md_log_path}: {e}")
    return wall_time, performance

def compute_statistics(data, harmonic=False):
    if not data:
        return None, None
    mean = stats.hmean(data) if harmonic else np.mean(data)
    ci = stats.t.interval(0.95, len(data)-1, loc=mean, scale=stats.sem(data)) if len(data) > 1 else (mean, mean)
    error = (ci[1] - ci[0]) / 2 if len(data) > 1 else 0
    return mean, error

def process_data(input_directory):
    records = []
    gromacs_path = os.path.join(input_directory, "gromacs")

    for system in os.listdir(gromacs_path):
        system_path = os.path.join(gromacs_path, system)
        if not os.path.isdir(system_path):
            continue

        for testcase in os.listdir(system_path):
            testcase_path = os.path.join(system_path, testcase)
            if not os.path.isdir(testcase_path):
                continue

            wall_times = []
            performances = []
            for run_dir in os.listdir(testcase_path):
                run_path = os.path.join(testcase_path, run_dir, "md.log")
                if os.path.exists(run_path):
                    wall, perf = extract_values(run_path)
                    if wall is not None and perf is not None:
                        wall_times.append(wall)
                        performances.append(perf)

            if wall_times and performances:
                wall_mean, wall_ci = compute_statistics(wall_times, harmonic=False)
                perf_hmean, perf_ci = compute_statistics(performances, harmonic=True)

                records.append({
                    "System": system,
                    "TestCase": testcase,
                    "Metric": "Execution Time",
                    "Mean": wall_mean,
                    "CI": wall_ci
                })
                records.append({
                    "System": system,
                    "TestCase": testcase,
                    "Metric": "Performance",
                    "Mean": perf_hmean,
                    "CI": perf_ci
                })
    return pd.DataFrame(records)

def plot_grouped_bar(df, metric_name):
    df_metric = df[df["Metric"] == metric_name]
    systems = df_metric["System"].unique()

    fig, axs = plt.subplots(1, len(systems), figsize=(20, 6), sharey=False)
    if len(systems) == 1:
        axs = [axs]

    desired_order = ["naive", "native", "spack", "optimized_spack", "specialized", "xaas"]

    for ax, (system, group) in zip(axs, df_metric.groupby("System")):
        # Filter and reorder only available test cases
        available = [tc for tc in desired_order if tc in group["TestCase"].values]
        group = group.set_index("TestCase").loc[available].reset_index()

        # Assign system-specific color
        system_color = {
            "ault23": "#E10909",     # red
            "aurora": "#237CCC",     # blue
            "clariden": "#067114",   # green
        }.get(system.lower(), "gray")

        palette = {tc: system_color for tc in available}

        # Plot bars
        sns.barplot(
            data=group,
            x="TestCase",
            y="Mean",
            palette=palette,
            ax=ax,
            errorbar=None
        )

        # Add error bars manually aligned to bars
        for bar, (_, row) in zip(ax.patches, group.iterrows()):
            x = bar.get_x() + bar.get_width() / 2
            y = row["Mean"]
            err = row["CI"]
            ax.errorbar(x=x, y=y, yerr=err, fmt='none', ecolor='black', capsize=5)

        # Titles and axes
        system_titles = {
            "clariden": "Clariden-Alps",
            "aurora": "Aurora",
            "ault23": "Ault23"
        }
        ax.set_title(system_titles.get(system.lower(), system.capitalize()), fontweight='bold')
        ax.set_xlabel("Build Settings", fontweight='bold', color="#333333")
        ax.set_ylabel("Execution Time (s)" if metric_name == "Execution Time" else "Performance (ns/day)",
                      fontweight='bold', color="#333333")
        ax.set_xticks(range(len(available)))
        ax.set_xticklabels(
            [legends.get(label, label) for label in available],
            rotation=45,
            ha='right',
            fontweight='bold',
            color="#333333"
        )
        ax.tick_params(axis='y', labelsize=10, labelcolor="#333333")
        ax.yaxis.set_major_locator(plt.MaxNLocator(integer=True, prune='lower'))

        if ax.get_legend() is not None:
            ax.get_legend().remove()

    fig.suptitle(f"GROMACS {metric_name} for UEABS's Test Case B", fontsize=14, fontweight='bold')
    fig.tight_layout(rect=[0, 0.05, 1, 0.95])

    handles, labels = axs[0].get_legend_handles_labels()
    if handles and labels:
        fig.legend(handles, [legends.get(lbl, lbl) for lbl in labels], loc='upper center', ncol=len(labels))

    plt.show()

def main():
    parser = argparse.ArgumentParser(description="Plot GROMACS benchmark data with Seaborn.")
    parser.add_argument("input_directory", type=str, help="Root of the hpc-benchmarks directory")
    args = parser.parse_args()

    df = process_data(args.input_directory)
    if not df.empty:
        plot_grouped_bar(df, "Execution Time")
        plot_grouped_bar(df, "Performance")
    else:
        print("No data found.")

if __name__ == "__main__":
    main()