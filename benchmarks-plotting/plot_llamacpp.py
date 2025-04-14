import os
import sys
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Command-line path
if len(sys.argv) != 2:
    print("Usage: python plot_llamacpp.py <path-to-parent-dir>")
    sys.exit(1)

ROOT_DIR = os.path.abspath(os.path.join(sys.argv[1], "llamma.cpp"))
if not os.path.isdir(ROOT_DIR):
    print(f"Directory not found: {ROOT_DIR}")
    sys.exit(1)

# Build order
build_order = [
    "Naive",
    "Specialized",
    "Specialized Container",
    "Xaas Source Container"
]

# Color coding per system
system_colors = {
    "ault23": "red",
    "aurora": "blue",
    "clariden": "green"
}

execution_data = []
throughput_data = []

# Traverse each system
for system in os.listdir(ROOT_DIR):
    system_path = os.path.join(ROOT_DIR, system, "benchmarks", "Q4_K_M")
    if not os.path.isdir(system_path):
        continue

    pretty_system = "Clariden-Alps" if system.lower() == "clariden" else system.capitalize()
    system_color = system_colors.get(system.lower(), "gray")

    for file in os.listdir(system_path):
        if not file.endswith(".csv"):
            continue

        file_path = os.path.join(system_path, file)
        if os.path.getsize(file_path) == 0:
            continue

        try:
            df = pd.read_csv(file_path)
            if df.empty:
                continue
        except Exception:
            continue

        config_name = os.path.splitext(file)[0].replace("_", " ").title()
        if config_name not in build_order:
            continue

        last_row = df.iloc[-1]

        # Convert both avg_ns and stddev_ns to seconds here
        avg_ns_sec = float(last_row["avg_ns"]) / 1e9
        stddev_ns_sec = float(last_row["stddev_ns"]) / 1e9

        execution_data.append({
            "System": pretty_system,
            "Build": config_name,
            "Value": avg_ns_sec,
            "Std": stddev_ns_sec,
            "Color": system_color
        })
        throughput_data.append({
            "System": pretty_system,
            "Build": config_name,
            "Value": float(last_row["avg_ts"]),
            "Std": float(last_row["stddev_ts"]),
            "Color": system_color
        })

# Create DataFrames
df_exec = pd.DataFrame(execution_data)
df_thru = pd.DataFrame(throughput_data)

# Apply category ordering
df_exec["Build"] = pd.Categorical(df_exec["Build"], categories=build_order, ordered=True)
df_thru["Build"] = pd.Categorical(df_thru["Build"], categories=build_order, ordered=True)

sns.set_style("darkgrid", {"grid.color": ".6", "grid.linestyle": ":"})

# --- Plot 1: Execution Time ---
g1 = sns.FacetGrid(df_exec, col="System", sharey=False, height=5, aspect=1.4)
g1.map_dataframe(sns.barplot, x="Build", y="Value", ci=None, dodge=False)
for ax, system in zip(g1.axes.flat, df_exec["System"].unique()):
    data = df_exec[df_exec["System"] == system]
    color = data["Color"].iloc[0]
    for patch, row in zip(ax.patches, data.itertuples()):
        patch.set_color(color)
        bar_x = patch.get_x() + patch.get_width() / 2
        bar_y = patch.get_height()
        ax.errorbar(bar_x, bar_y, yerr=row.Std, fmt='none', c='black', capsize=5)
        ax.text(bar_x, bar_y + bar_y * 0.02, f"{bar_y:.3f}", ha='center', va='bottom', fontsize=9)
    ax.set_xticklabels(ax.get_xticklabels(), rotation=45, color="#333333")
    ax.set_xlabel("Build Configuration", weight="bold", color="#333333")
    ax.set_ylabel("Execution Time (s)", weight="bold", color="#333333")
g1.set_titles("{col_name}", weight="bold")
plt.subplots_adjust(top=0.85)
g1.fig.suptitle("llama.cpp Inference Time Per Build Configuration using Llama-2-13B-chat Model", weight="bold")
plt.tight_layout()
plt.show()

# --- Plot 2: Throughput ---
g2 = sns.FacetGrid(df_thru, col="System", sharey=False, height=5, aspect=1.4)
g2.map_dataframe(sns.barplot, x="Build", y="Value", ci=None, dodge=False)
for ax, system in zip(g2.axes.flat, df_thru["System"].unique()):
    data = df_thru[df_thru["System"] == system]
    color = data["Color"].iloc[0]
    for patch, row in zip(ax.patches, data.itertuples()):
        patch.set_color(color)
        bar_x = patch.get_x() + patch.get_width() / 2
        bar_y = patch.get_height()
        ax.errorbar(bar_x, bar_y, yerr=row.Std, fmt='none', c='black', capsize=5)
        ax.text(bar_x, bar_y + bar_y * 0.02, f"{bar_y:.1f}", ha='center', va='bottom', fontsize=9)
    ax.set_xticklabels(ax.get_xticklabels(), rotation=45, color="#333333")
    ax.set_xlabel("Build Configuration", weight="bold", color="#333333")
    ax.set_ylabel("Throughput (tokens/sec)", weight="bold", color="#333333")
g2.set_titles("{col_name}", weight="bold")
plt.subplots_adjust(top=0.85)
g2.fig.suptitle("llama.cpp Throughput Per Build Configuration using Llama-2-13B-chat Model", weight="bold")
plt.tight_layout()
plt.show()