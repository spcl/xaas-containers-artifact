import os
import sys
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

import matplotlib

matplotlib.rcParams["pdf.fonttype"] = 42
matplotlib.rcParams["ps.fonttype"] = 42

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))

DATA_DIR = os.path.join(
    CURRENT_DIR, os.path.pardir, os.path.pardir, "benchmarks-source", "llama.cpp"
)

mapping_experiments = {
    "ault23": {
        "testcase0": "Naive",
        "testcase1": "Specialized",
        "testcase2": "Specialized Container",
        "testcase3": "XaaS Source Container",
    },
    "clariden": {
        "testcase0": "Naive",
        "testcase1": "Specialized",
        "testcase2": "Specialized Container",
        "testcase3": "XaaS Source Container",
    },
    "aurora": {
        "testcase0": "Specialized",
        "testcase1": "XaaS Source Container",
        "testcase2": "Naive",
    },
}

# Build order
build_order = ["Naive", "Specialized", "Specialized Container", "XaaS Source Container"]

legends = {
    "native": "Native\nBuild",
    "module": "Module",
    "Naive": "Naive\nBuild",
    "spack": "Spack",
    "optimized_spack": "Spack optimized",
    "xaas": "XaaS\nSource",
    "Specialized": "Specialized",
    "Specialized Container": "Specialized\nContainer",
    "XaaS Source Container": "Xaas Source\nContainer",
}

# Color coding per system
system_colors = {"ault23": "red", "aurora": "blue", "clariden": "green"}

execution_data = []
throughput_data = []

# Traverse each system
for system in os.listdir(DATA_DIR):
    system_path = os.path.join(DATA_DIR, system, "llama-benchmarks", "Q4_K_M")
    if not os.path.isdir(system_path):
        continue

    pretty_system = (
        "Clariden-Alps" if system.lower() == "clariden" else system.capitalize()
    )
    system_color = system_colors.get(system.lower(), "gray")

    for file in os.listdir(system_path):
        if not file.endswith(".csv"):
            continue

        file_path = os.path.join(system_path, file)
        print(f"Processing file: {file_path}")
        if os.path.getsize(file_path) == 0:
            continue

        try:
            df = pd.read_csv(file_path)
            if df.empty:
                continue
        except Exception:
            continue

        config_name = os.path.splitext(file)[0].split("_")[0]

        config_name = mapping_experiments[system.lower()][config_name]

        if config_name not in build_order:
            continue

        print(f"Processing {system} - {config_name}")

        last_row = df.iloc[-1]

        avg_ns_sec = float(last_row["avg_ns"]) / 1e9
        stddev_ns_sec = float(last_row["stddev_ns"]) / 1e9
        print(system, file, avg_ns_sec, stddev_ns_sec)

        execution_data.append(
            {
                "System": pretty_system,
                "Build": config_name,
                "Value": avg_ns_sec,
                "Std": stddev_ns_sec,
                "Color": system_color,
            }
        )
        throughput_data.append(
            {
                "System": pretty_system,
                "Build": config_name,
                "Value": float(last_row["avg_ts"]),
                "Std": float(last_row["stddev_ts"]),
                "Color": system_color,
            }
        )

# Create DataFrames
df_exec = pd.DataFrame(execution_data)
df_thru = pd.DataFrame(throughput_data)

sns.set_style("darkgrid", {"grid.color": ".6", "grid.linestyle": ":"})

# --- Plot 1: Execution Time ---
systems = df_exec["System"].unique()
fig1, axs1 = plt.subplots(
    1, len(systems), figsize=(10, 4), width_ratios=[4, 4, 2], sharey=False
)
if len(systems) == 1:
    axs1 = [axs1]
i = 0
for ax, system in zip(axs1, systems):
    data = df_exec[df_exec["System"] == system]
    system_order = [b for b in build_order if b in data["Build"].values]

    bar_width = 0.5 if system.lower() == "aurora" else 0.8
    sns.barplot(
        data=data,
        x="Build",
        y="Value",
        order=system_order,
        ax=ax,
        ci=None,
        width=bar_width,
    )
    color = data["Color"].iloc[0]

    # for patch, row in zip(ax.patches, data.itertuples()):
    for patch, build in zip(ax.patches, system_order):
        patch.set_color(color)
        bar_x = patch.get_x() + patch.get_width() / 2
        bar_y = patch.get_height()

        row = data.loc[data["Build"] == build].iloc[0]
        ax.errorbar(bar_x, bar_y, yerr=row.Std, fmt="none", c="black", capsize=5)
        ax.text(
            bar_x,
            bar_y + bar_y * 0.02,
            f"{bar_y:.3f}",
            ha="center",
            va="bottom",
            fontsize=12,
        )

    print("legend", [legends[label] for label in system_order])
    ax.set_xticklabels(
        [legends.get(label, label) for label in system_order],
        rotation=45,
        fontsize=14,
        fontweight="bold",
        color="#333333",
    )
    # ax.set_xlabel("Build Configuration", weight="bold", color="#333333")
    if i == 0:
        ax.set_ylabel("Execution Time (s)", weight="bold", color="#333333", fontsize=14)
    else:
        ax.set_ylabel("")
    ax.set_title(system, weight="bold")
    ax.set_xlabel("")

    if i == 2:
        ax.set_ylim([0, 7.5])

    i += 1

#    "llama.cpp Inference Time Per Build Configuration using Llama-2-13B-chat Model",
# fig1.suptitle(
#    weight="bold",
# )
plt.tight_layout()

plt.savefig(os.path.join(CURRENT_DIR, "llama_portability.pdf"), bbox_inches="tight")

# --- Plot 2: Throughput ---
# systems = df_thru["System"].unique()
# fig2, axs2 = plt.subplots(1, len(systems), figsize=(5 * len(systems), 5), sharey=False)
# if len(systems) == 1:
#    axs2 = [axs2]
#
# for ax, system in zip(axs2, systems):
#    data = df_thru[df_thru["System"] == system]
#    system_order = [b for b in build_order if b in data["Build"].values]
#
#    bar_width = 0.5 if system.lower() == "aurora" else 0.8
#    sns.barplot(
#        data=data,
#        x="Build",
#        y="Value",
#        order=system_order,
#        ax=ax,
#        ci=None,
#        width=bar_width,
#    )
#    color = data["Color"].iloc[0]
#
#    for patch, row in zip(ax.patches, data.itertuples()):
#        patch.set_color(color)
#        bar_x = patch.get_x() + patch.get_width() / 2
#        bar_y = patch.get_height()
#        ax.errorbar(bar_x, bar_y, yerr=row.Std, fmt="none", c="black", capsize=5)
#        ax.text(
#            bar_x,
#            bar_y + bar_y * 0.02,
#            f"{bar_y:.1f}",
#            ha="center",
#            va="bottom",
#            fontsize=9,
#        )
#
#    ax.set_xticklabels(system_order, rotation=45, color="#333333")
#    ax.set_xlabel("Build Configuration", weight="bold", color="#333333")
#    ax.set_ylabel("Throughput (tokens/sec)", weight="bold", color="#333333")
#    ax.set_title(system, weight="bold")
#
# fig2.suptitle(
#    "llama.cpp Throughput Per Build Configuration using Llama-2-13B-chat Model",
#    weight="bold",
# )
# plt.tight_layout()
# plt.show()
