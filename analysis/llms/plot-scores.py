import os
import json
import re
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
DATA_DIR = os.path.join(
    CURRENT_DIR,
    os.path.pardir,
    os.path.pardir,
    "benchmarks-llms",
)


def normalize_key(key):
    return key.replace('-', '_').replace(' ', '_').lower()

def normalize_flag(flag):
    if not flag:
        return None
    return flag.strip()  # Only strip whitespace, preserve `-D`

def extract_relevant_fields(json_data):
    flattened = {}

    # gpu_build
    if "gpu_build" in json_data:
        flattened["gpu_build.value"] = json_data["gpu_build"].get("value")
        flattened["gpu_build.build_flag"] = normalize_flag(json_data["gpu_build"].get("build_flag"))

    # gpu_backends
    if "gpu_backends" in json_data:
        for backend, info in json_data["gpu_backends"].items():
            b_key = normalize_key(backend)
            flattened[f"gpu_backends.{b_key}.used_as_default"] = info.get("used_as_default")
            flattened[f"gpu_backends.{b_key}.build_flag"] = normalize_flag(info.get("build_flag"))

    # linear_algebra_libraries
    if "linear_algebra_libraries" in json_data:
        for lib, info in json_data["linear_algebra_libraries"].items():
            l_key = normalize_key(lib)
            flattened[f"linear_algebra_libraries.{l_key}.used_as_default"] = info.get("used_as_default")

    # FFT_libraries
    if "FFT_libraries" in json_data:
        for lib, info in json_data["FFT_libraries"].items():
            f_key = normalize_key(lib)
            flattened[f"FFT_libraries.{f_key}.built-in"] = info.get("built-in")
            flattened[f"FFT_libraries.{f_key}.used_as_default"] = info.get("used_as_default")
            flattened[f"FFT_libraries.{f_key}.build_flag"] = normalize_flag(info.get("build_flag"))

    # simd_vectorization
    if "simd_vectorization" in json_data:
        for simd, info in json_data["simd_vectorization"].items():
            s_key = normalize_key(simd)
            flattened[f"simd_vectorization.{s_key}.build_flag"] = normalize_flag(info.get("build_flag"))
            flattened[f"simd_vectorization.{s_key}.default"] = info.get("default")

    # build_system
    if "build_system" in json_data:
        flattened["build_system.type"] = normalize_key(json_data["build_system"].get("type"))
        flattened["build_system.minimum_version"] = json_data["build_system"].get("minimum_version")

    # internal_build
    if "internal_build" in json_data:
        flattened["internal_build.library_name"] = normalize_key(json_data["internal_build"].get("library_name"))
        flattened["internal_build.build_flag"] = normalize_flag(json_data["internal_build"].get("build_flag"))

    return flattened

def compare_dicts(gt, pred):
    tp = fp = fn = 0
    all_keys = set(gt.keys()).union(pred.keys())
    for key in all_keys:
        gt_val = gt.get(key)
        pred_val = pred.get(key)
        if gt_val is not None and pred_val is not None:
            if gt_val == pred_val:
                tp += 1
            else:
                fp += 1
        elif pred_val is not None:
            fp += 1
        elif gt_val is not None:
            fn += 1
    return tp, fp, fn

def compute_metrics(tp, fp, fn):
    precision = tp / (tp + fp) if tp + fp else 0.0
    recall = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    return precision, recall, f1

def evaluate_models(base_dir, ground_truth_path):
    with open(ground_truth_path, 'r') as f:
        ground_truth_json = json.load(f)
    gt_flat = extract_relevant_fields(ground_truth_json)

    model_dirs = [
        "chatgpt-o3-mini",
        "chatgpt-gpt4o",
        "gemini-flash-1.5",
        "gemini-flash-2",
        #"gemini-2.5-pro",
        "claude-3-5-haiku",
        "claude-3-5-sonnet",
        "claude-3-7-sonnet",
        #"llama3"
    ]

    long_metrics = []  # For plotting

    for model_dir in model_dirs:
        model_path = os.path.join(base_dir, model_dir)
        if not os.path.isdir(model_path):
            continue

        for i in range(1, 11):
            pred_file = os.path.join(model_path, f"specialization_point_{i}.json")
            if not os.path.isfile(pred_file):
                continue
            try:
                with open(pred_file, 'r') as pf:
                    pred_json = json.load(pf)
                    pred_flat = extract_relevant_fields(pred_json)
                    tp, fp, fn = compare_dicts(gt_flat, pred_flat)
                    precision, recall, f1 = compute_metrics(tp, fp, fn)

                    long_metrics.extend([
                        {"Model": model_dir, "Metric": "F1 Score", "Value": f1},
                        {"Model": model_dir, "Metric": "Precision", "Value": precision},
                        {"Model": model_dir, "Metric": "Recall", "Value": recall}
                    ])
            except Exception as e:
                print(f"Error processing {pred_file}: {e}")

    return pd.DataFrame(long_metrics)


def plot_metric_boxplots(df):
    plt.figure(figsize=(14, 6))

    # Grouped boxplot: one per metric per model
    ax = sns.boxplot(data=df, x="Model", y="Value", hue="Metric", notch=False, fill=False)

    # Customize appearance
    plt.title("Distribution of F1 Score, Precision, and Recall per Model")
    plt.ylabel("Score")
    plt.xlabel("Model")
    plt.xticks(rotation=45, ha="right")
    plt.grid(True, axis="y", linestyle="--", alpha=0.5)
    plt.legend(title="Metric")

    plt.tight_layout()
    plt.savefig(os.path.join(CURRENT_DIR, "metrics_boxplot.pdf"), bbox_inches='tight')

def print_metric_statistics(df):
    print("\n📊 Metric Summary (Mean, Median, Min, Max per Model/Metric):\n")
    grouped = df.groupby(["Model", "Metric"])["Value"]
    summary = grouped.agg(['mean', 'median', 'min', 'max']).round(4)
    print(summary.to_string())


if __name__ == "__main__":

    ground_truth = os.path.join(DATA_DIR, "ground_truth.json")
    metrics_df = evaluate_models(DATA_DIR, ground_truth)

    print_metric_statistics(metrics_df)

    plot_metric_boxplots(metrics_df)
