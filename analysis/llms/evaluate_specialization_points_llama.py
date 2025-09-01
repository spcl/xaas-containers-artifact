import os
import json
import re
import argparse
import pandas as pd
import numpy as np


CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
DATA_DIR = os.path.join(
    CURRENT_DIR,
    os.path.pardir,
    os.path.pardir,
    "benchmarks-llms",
    "microbenchmark-llama",
)


def normalize_key(key):
    if key is None:
        return None
    return key.replace("-", "_").replace(" ", "_").lower()


def normalize_flag(flag, normalize_cmake_regex_flag):
    if not flag:
        return None
    if re.match(r"-D.*=ON$", flag):
        # normalize by stripping =ON
        return flag.replace("=ON", "")
    if normalize_cmake_regex_flag and not flag.startswith("-D"):
        return f"-D{flag.strip()}"
    return flag.strip()  # Only strip whitespace, preserve `-D`


def normalize_vectorization_name(key):
    if not key:
        return None
    return key.replace("-", "_").replace(" ", "").replace("_", "").lower()


def extract_relevant_fields(
    json_data,
    normalize_vectorization_name_flag: bool,
    normalize_cmake_regex_flag: bool,
    eval_opt_flags: bool,
):
    flattened = {}

    if "parallel_programming_libraries" in json_data:
        for lib, info in json_data["parallel_programming_libraries"].items():
            key = normalize_key(lib)
            flattened[f"parallel_programming_libraries.{key}.used_as_default"] = (
                info.get("used_as_default")
            )
            flattened[f"parallel_programming_libraries.{key}.build_flag"] = (
                normalize_flag(info.get("build_flag"), normalize_cmake_regex_flag)
            )

    # gpu_build
    if "gpu_build" in json_data:
        flattened["gpu_build.value"] = json_data["gpu_build"].get("value")
        flattened["gpu_build.build_flag"] = normalize_flag(
            json_data["gpu_build"].get("build_flag"), normalize_cmake_regex_flag
        )

    # gpu_backends
    if "gpu_backends" in json_data:
        for backend, info in json_data["gpu_backends"].items():
            b_key = normalize_key(backend)
            flattened[f"gpu_backends.{b_key}.used_as_default"] = info.get(
                "used_as_default"
            )
            flattened[f"gpu_backends.{b_key}.build_flag"] = normalize_flag(
                info.get("build_flag"), normalize_cmake_regex_flag
            )

    # linear_algebra_libraries
    if "linear_algebra_libraries" in json_data:
        for lib, info in json_data["linear_algebra_libraries"].items():
            l_key = normalize_key(lib)
            flattened[f"linear_algebra_libraries.{l_key}.used_as_default"] = info.get(
                "used_as_default"
            )
            flattened[f"linear_algebra_libraries.{l_key}.build_flag"] = normalize_flag(
                info.get("build_flag"), normalize_cmake_regex_flag
            )

    # FFT_libraries
    if "FFT_libraries" in json_data:
        for lib, info in json_data["FFT_libraries"].items():
            f_key = normalize_key(lib)
            flattened[f"FFT_libraries.{f_key}.built-in"] = info.get("built-in")
            flattened[f"FFT_libraries.{f_key}.used_as_default"] = info.get(
                "used_as_default"
            )
            flattened[f"FFT_libraries.{f_key}.build_flag"] = normalize_flag(
                info.get("build_flag"), normalize_cmake_regex_flag
            )

    # simd_vectorization
    if "simd_vectorization" in json_data:
        for simd, info in json_data["simd_vectorization"].items():
            if normalize_vectorization_name_flag:
                s_key = normalize_vectorization_name(simd)
            else:
                s_key = normalize_key(simd)

            flattened[f"simd_vectorization.{s_key}.build_flag"] = normalize_flag(
                info.get("build_flag"), normalize_cmake_regex_flag
            )
            flattened[f"simd_vectorization.{s_key}.default"] = info.get("default")

    # build_system
    if "build_system" in json_data:
        flattened["build_system.type"] = normalize_key(
            json_data["build_system"].get("type")
        )
        flattened["build_system.minimum_version"] = json_data["build_system"].get(
            "minimum_version"
        )

    # internal_build
    if "internal_build" in json_data:
        flattened["internal_build.library_name"] = normalize_key(
            json_data["internal_build"].get("library_name")
        )
        flattened["internal_build.build_flag"] = normalize_flag(
            json_data["internal_build"].get("build_flag"), normalize_cmake_regex_flag
        )

    if eval_opt_flags:
        if "optimization_build_flags" in json_data:
            for i, flag in enumerate(json_data["optimization_build_flags"]):
                flattened[f"optimization_build_flags.{flag}"] = True

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
                print("fp", key, gt_val, pred_val)
        elif pred_val is not None:
            print("fp", key, gt_val, pred_val)
            fp += 1
        elif gt_val is not None:
            print("fn", key, gt_val, pred_val)
            fn += 1
    return tp, fp, fn


def compute_metrics(tp, fp, fn):
    precision = tp / (tp + fp) if tp + fp else 0.0
    recall = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    return precision, recall, f1


def evaluate_models(
    base_dir,
    ground_truth_path,
    normalize_vectorization_name_flag: bool,
    normalize_cmake_regex_flag: bool,
    eval_opt_flags: bool,
):
    with open(ground_truth_path, "r") as f:
        ground_truth_json = json.load(f)
    gt_flat = extract_relevant_fields(
        ground_truth_json,
        normalize_vectorization_name_flag,
        normalize_cmake_regex_flag,
        eval_opt_flags,
    )

    model_dirs = [
        "chatgpt-gpt4o",
        "chatgpt-o3-mini",
        "gemini-flash-1.5",
        "gemini-flash-2",
        "gemini-2.5-pro",
        "claude-3-5-haiku",
        "claude-3-5-sonnet",
        "claude-3-7-sonnet",
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
                with open(pred_file, "r") as pf:
                    pred_json = json.load(pf)
                    pred_flat = extract_relevant_fields(
                        pred_json,
                        normalize_vectorization_name_flag,
                        normalize_cmake_regex_flag,
                        eval_opt_flags,
                    )
                    tp, fp, fn = compare_dicts(gt_flat, pred_flat)
                    precision, recall, f1 = compute_metrics(tp, fp, fn)
                    precisions.append(precision)
                    recalls.append(recall)
                    f1s.append(f1)
            except Exception as e:
                print(f"Error processing {pred_file}: {e}")

        # Compute averages across 10 runs
        avg_precision = (
            round(sum(precisions) / len(precisions), 4) if precisions else 0.0
        )
        avg_recall = round(sum(recalls) / len(recalls), 4) if recalls else 0.0
        avg_f1 = round(sum(f1s) / len(f1s), 4) if f1s else 0.0

        results[model_dir] = {
            "F1 Score (Min)": round(np.min(f1s), 4),
            "F1 Score (Median)": round(np.median(f1s), 4),
            "F1 Score (Avg)": round(np.mean(f1s), 4),
            "F1 Score (Max)": round(np.max(f1s), 4),
            "Precision Score (Min)": round(np.min(precisions), 4),
            "Precision Score (Median)": round(np.median(precisions), 4),
            "Precision Score (Avg)": round(np.mean(precisions), 4),
            "Precision Score (Max)": round(np.max(precisions), 4),
            "Recall Score (Min)": round(np.min(recalls), 4),
            "Recall Score (Median)": round(np.median(recalls), 4),
            "Recall Score (Avg)": round(np.mean(recalls), 4),
            "Recall Score (Max)": round(np.max(recalls), 4),
        }

    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--normalize-vectorization-name",
        action=argparse.BooleanOptionalAction,
        type=bool,
    )
    parser.add_argument(
        "--normalize-cmake-regex-flag",
        action=argparse.BooleanOptionalAction,
        type=bool,
    )
    parser.add_argument(
        "--eval-opt-flags",
        action=argparse.BooleanOptionalAction,
        type=bool,
    )
    args = parser.parse_args()

    ground_truth = os.path.join(DATA_DIR, "ground_truth.json")

    results = evaluate_models(
        DATA_DIR,
        ground_truth,
        args.normalize_vectorization_name,
        args.normalize_cmake_regex_flag,
        args.eval_opt_flags,
    )
    df = pd.DataFrame(results).T
    print(df)
