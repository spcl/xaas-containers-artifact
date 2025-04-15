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

sns.set_style("darkgrid", {"grid.color": ".6", "grid.linestyle": ":"})

# --- Plot 1: Execution Time ---
systems = df_exec["System"].unique()
fig1, axs1 = plt.subplots(1, len(systems), figsize=(5 * len(systems), 5), sharey=False)
if len(systems) == 1:
    axs1 = [axs1]

for ax, system in zip(axs1, systems):
    data = df_exec[df_exec["System"] == system]
    system_order = [b for b in build_order if b in data["Build"].values]

    bar_width = 0.5 if system.lower() == "aurora" else 0.8
    sns.barplot(data=data, x="Build", y="Value", order=system_order, ax=ax, ci=None, width=bar_width)
    color = data["Color"].iloc[0]

    for patch, row in zip(ax.patches, data.itertuples()):
        patch.set_color(color)
        bar_x = patch.get_x() + patch.get_width() / 2
        bar_y = patch.get_height()
        ax.errorbar(bar_x, bar_y, yerr=row.Std, fmt='none', c='black', capsize=5)
        ax.text(bar_x, bar_y + bar_y * 0.02, f"{bar_y:.3f}", ha='center', va='bottom', fontsize=9)

    ax.set_xticklabels(system_order, rotation=45, color="#333333")
    ax.set_xlabel("Build Configuration", weight="bold", color="#333333")
    ax.set_ylabel("Execution Time (s)", weight="bold", color="#333333")
    ax.set_title(system, weight="bold")

fig1.suptitle("llama.cpp Inference Time Per Build Configuration using Llama-2-13B-chat Model", weight="bold")
plt.tight_layout()
plt.show()

# --- Plot 2: Throughput ---
systems = df_thru["System"].unique()
fig2, axs2 = plt.subplots(1, len(systems), figsize=(5 * len(systems), 5), sharey=False)
if len(systems) == 1:
    axs2 = [axs2]

for ax, system in zip(axs2, systems):
    data = df_thru[df_thru["System"] == system]
    system_order = [b for b in build_order if b in data["Build"].values]

    bar_width = 0.5 if system.lower() == "aurora" else 0.8
    sns.barplot(data=data, x="Build", y="Value", order=system_order, ax=ax, ci=None, width=bar_width)
    color = data["Color"].iloc[0]

    for patch, row in zip(ax.patches, data.itertuples()):
        patch.set_color(color)
        bar_x = patch.get_x() + patch.get_width() / 2
        bar_y = patch.get_height()
        ax.errorbar(bar_x, bar_y, yerr=row.Std, fmt='none', c='black', capsize=5)
        ax.text(bar_x, bar_y + bar_y * 0.02, f"{bar_y:.1f}", ha='center', va='bottom', fontsize=9)

    ax.set_xticklabels(system_order, rotation=45, color="#333333")
    ax.set_xlabel("Build Configuration", weight="bold", color="#333333")
    ax.set_ylabel("Throughput (tokens/sec)", weight="bold", color="#333333")
    ax.set_title(system, weight="bold")

fig2.suptitle("llama.cpp Throughput Per Build Configuration using Llama-2-13B-chat Model", weight="bold")
plt.tight_layout()
plt.show()