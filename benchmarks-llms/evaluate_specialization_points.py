import os
import json
import re
import argparse
import pandas as pd

# to run the script: python evaluate_specialization_points.py --ground_truth ground_truth.json --base_dir . 


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
        "chatgpt-gpt4o",
        "chatgpt-o3-mini",
        "gemini-flash-1.5",
        "gemini-flash-2",
        "gemini-2.5-pro",
        "claude-3-5-haiku",
        "claude-3-5-sonnet",
        "claude-3-7-sonnet",
        "llama3"
    ]

    results = {}

    for model_dir in model_dirs:
        model_path = os.path.join(base_dir, model_dir)
        if not os.path.isdir(model_path):
            continue

        precisions = []
        recalls = []
        f1s = []

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
                    precisions.append(precision)
                    recalls.append(recall)
                    f1s.append(f1)
            except Exception as e:
                print(f"Error processing {pred_file}: {e}")

        # Compute averages across 10 runs
        avg_precision = round(sum(precisions) / len(precisions), 4) if precisions else 0.0
        avg_recall = round(sum(recalls) / len(recalls), 4) if recalls else 0.0
        avg_f1 = round(sum(f1s) / len(f1s), 4) if f1s else 0.0

        results[model_dir] = {
            "Precision": avg_precision,
            "Recall": avg_recall,
            "F1 Score": avg_f1
        }

    return results

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Evaluate LLM-generated specialization points.")
    parser.add_argument("--ground_truth", type=str, default="ground_truth.json", help="Path to ground truth JSON.")
    parser.add_argument("--base_dir", type=str, default=".", help="Base directory containing model folders.")
    args = parser.parse_args()

    results = evaluate_models(args.base_dir, args.ground_truth)
    df = pd.DataFrame(results).T
    print(df)