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

import matplotlib

matplotlib.rcParams["pdf.fonttype"] = 42
matplotlib.rcParams["ps.fonttype"] = 42

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))

DATA_DIR = os.path.join(
    CURRENT_DIR, os.path.pardir, os.path.pardir, "hpc-benchmarks", "gromacs"
)

mapping_experiments = {
    "ault23": {
        "testcase0": "naive",
        "testcase4": "spack",
        "testcase5": "optimized spack",
        "testcase3": "xaas",
    },
    "clariden": {
        "testcase0": "naive",
        "testcase4": "spack",
        "testcase5": "optimized spack",
        "testcase3": "xaas",
    },
    "aurora": {
        "native": "module",
        "specialized": "specialized",
        "source-container-default": "xaas",
        "source-container-gpu": "xaas_gpu",
    },
}

colors = {
    "native": "#6B6463",
    "naive": "#237CCC",
    "spack": "#FFD62B",
    "optimized_spack": "#5415F2",
    "xaas": "#E10909",
    "specialized": "#067114",
}

legends = {
    "native": "Native\nBuild",
    "module": "Module",
    "naive": "Naive\nBuild",
    "spack": "Spack",
    "optimized_spack": "Spack optimized",
    "xaas": "XaaS\nSource",
    "xaas_gpu": "XaaS\nSource\n+Manual",
    "specialized": "Container",
}


def extract_values(md_log_path):
    wall_time, performance = None, None
    try:
        with open(md_log_path, "r") as file:
            for line in file:
                if "Time:" in line:
                    time_values = re.findall(r"\d+\.\d+", line)
                    if len(time_values) >= 2:
                        wall_time = float(time_values[1])
                if "Performance:" in line:
                    perf_values = re.findall(r"\d+\.\d+", line)
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
    ci = (
        stats.t.interval(0.95, len(data) - 1, loc=mean, scale=stats.sem(data))
        if len(data) > 1
        else (mean, mean)
    )
    error = (ci[1] - ci[0]) / 2 if len(data) > 1 else 0
    return mean, error


def process_data(input_directory):
    records = []
    gromacs_path = input_directory

    for system in os.listdir(gromacs_path):
        system_path = os.path.join(gromacs_path, system, "gromacs-benchmarks")
        if not os.path.isdir(system_path):
            continue

        benchmarks_path = os.path.join(system_path, "TestcaseB_benchmarks")

        for testcase in os.listdir(benchmarks_path):
            testcase_path = os.path.join(benchmarks_path, testcase)
            print(testcase_path)
            if not os.path.isdir(testcase_path):
                continue

            testcase_name = testcase.split("_")[1]

            if testcase_name not in mapping_experiments.get(system.lower(), {}):
                continue

            # we map from system specific naming to the one that our plotting can understand
            testcase = mapping_experiments[system][testcase_name]

            wall_times = []
            performances = []
            for run_dir in os.listdir(testcase_path):
                run_path = os.path.join(testcase_path, run_dir, "md.log")
                if os.path.exists(run_path):
                    wall, perf = extract_values(run_path)
                    if wall is not None and perf is not None:
                        wall_times.append(wall)
                        performances.append(perf)

            print(
                f"Processing {system} - {testcase_name}, samples: {len(wall_times)}, {len(performances)}"
            )

            if wall_times and performances:
                wall_mean, wall_ci = compute_statistics(wall_times, harmonic=False)
                perf_hmean, perf_ci = compute_statistics(performances, harmonic=True)

                records.append(
                    {
                        "System": system,
                        "TestCase": testcase,
                        "Metric": "Execution Time",
                        "Mean": wall_mean,
                        "CI": wall_ci,
                    }
                )
                records.append(
                    {
                        "System": system,
                        "TestCase": testcase,
                        "Metric": "Performance",
                        "Mean": perf_hmean,
                        "CI": perf_ci,
                    }
                )

    return pd.DataFrame(records)


def plot_grouped_bar(df, metric_name):
    df_metric = df[df["Metric"] == metric_name]
    systems = df_metric["System"].unique()

    fig, axs = plt.subplots(
        1, len(systems), figsize=(10, 4), width_ratios=[2, 3, 2], sharey=False
    )
    if len(systems) == 1:
        axs = [axs]

    desired_order = [
        "naive",
        "native",
        "spack",
        "optimized_spack",
        "specialized",
        "xaas_gpu",
        "xaas",
        "module",
    ]

    i = 0
    for ax, (system, group) in zip(axs, df_metric.groupby("System")):
        # Filter and reorder only available test cases
        available = [tc for tc in desired_order if tc in group["TestCase"].values]
        group = group.set_index("TestCase").loc[available].reset_index()

        # Assign system-specific color
        system_color = {
            "ault23": "#E10909",  # red
            "aurora": "#237CCC",  # blue
            "clariden": "#067114",  # green
        }.get(system.lower(), "gray")

        palette = {tc: system_color for tc in available}

        # Plot bars
        sns.barplot(
            data=group, x="TestCase", y="Mean", palette=palette, ax=ax, errorbar=None
        )

        # Add error bars manually aligned to bars
        for bar, (_, row) in zip(ax.patches, group.iterrows()):
            x = bar.get_x() + bar.get_width() / 2
            y = row["Mean"]
            err = row["CI"]
            ax.errorbar(x=x, y=y, yerr=err, fmt="none", ecolor="black", capsize=5)

        # Titles and axes
        system_titles = {
            "clariden": "Clariden-Alps",
            "aurora": "Aurora",
            "ault23": "Ault23",
        }
        ax.set_title(
            system_titles.get(system.lower(), system.capitalize()),
            fontweight="bold",
            fontsize=16,
        )
        # ax.set_xlabel("Build Settings", fontweight="bold", color="#333333")
        ax.set_xlabel("")
        # ax.set_title("")
        if i == 0:
            ax.set_ylabel(
                "Execution Time (s)"
                if metric_name == "Execution Time"
                else "Performance (ns/day)",
                fontweight="bold",
                fontsize=14,
                color="#333333",
            )
        else:
            ax.set_ylabel("")
        ax.set_xticks(range(len(available)))
        ax.set_xticklabels(
            [legends.get(label, label) for label in available],
            # rotation=20,
            ha="center",
            fontweight="bold",
            fontsize=14,
            color="#333333",
        )
        ax.tick_params(axis="y", labelsize=12, labelcolor="#333333")
        ax.yaxis.set_major_locator(plt.MaxNLocator(integer=True, prune="lower"))

        if ax.get_legend() is not None:
            ax.get_legend().remove()

        i += 1

        # fig.suptitle(
        #    f"GROMACS {metric_name} for UEABS's Test Case B", fontsize=14, fontweight="bold"
        # )
    fig.tight_layout(rect=[0, 0.05, 1, 0.95])

    handles, labels = axs[0].get_legend_handles_labels()
    if handles and labels:
        fig.legend(
            handles,
            [legends.get(lbl, lbl) for lbl in labels],
            loc="upper center",
            ncol=len(labels),
        )
    plt.tight_layout()

    plt.savefig(
        os.path.join(CURRENT_DIR, "gromacs_portability.pdf"), bbox_inches="tight"
    )

    # plt.show()


def main():
    df = process_data(DATA_DIR)
    if not df.empty:
        plot_grouped_bar(df, "Execution Time")
        # plot_grouped_bar(df, "Performance")
    else:
        print("No data found.")


if __name__ == "__main__":
    main()
