import os
import json
from statistics import mean, stdev

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
DATA_DIR = os.path.join(
    CURRENT_DIR,
    os.path.pardir,
    os.path.pardir,
    "benchmarks-llms",
)

# Define model pricing in $ per 1M tokens
pricing_per_million = {
    "chatgpt-gpt4o": {"input": 2.5, "output": 10},
    "chatgpt-o3-mini": {"input": 1.1, "output": 4.4},
    "claude-3-7-sonnet": {"input": 3, "output": 15},
    "claude-3-5-sonnet": {"input": 3, "output": 15},
    "claude-3-5-haiku": {"input": 0.8, "output": 4},
    "gemini-flash-2": {"input": 0.10, "output": 0.40},
    "gemini-flash-1.5": {"input": 0.075, "output": 0.30},  # assuming <128K
    "gemini-2.5-pro": {"input": 1.25, "output": 10.00},  # assuming <= 200K
    "llama3": {"input": 0.0, "output": 0.0},
    "ollama": {"input": 0.0, "output": 0.0},
}


def find_model_dirs():
    prefixes = ("claude-", "chatgpt-", "gemini-", "llama", "ollama")
    paths = [d for d in os.listdir(DATA_DIR) if d.startswith(prefixes)]
    print([d for d in paths if d.startswith(prefixes)])
    return [d for d in paths if os.path.isdir(os.path.join(DATA_DIR, d))]


def load_statistics(file_path):
    try:
        with open(file_path, "r") as f:
            return json.load(f)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return []


def compute_stats(values):
    if not values:
        return (0.0, 0.0)
    return (mean(values), stdev(values) if len(values) > 1 else 0.0)


def compute_cost(input_tokens, output_tokens, model_name):
    # Step 1: Get average input tokens
    avg_input_tokens = mean(input_tokens) if input_tokens else 0.0

    # Step 2: Get average output tokens
    avg_output_tokens = mean(output_tokens) if output_tokens else 0.0

    # Step 3: Find cost per run using pricing per 1M tokens
    pricing = pricing_per_million.get(model_name, {"input": 0.0, "output": 0.0})
    input_cost = avg_input_tokens / 1_000_000 * pricing["input"]
    output_cost = avg_output_tokens / 1_000_000 * pricing["output"]
    cost_per_run = input_cost + output_cost

    return round(cost_per_run, 6)


def summarize_model(model_dir):
    stats_file = os.path.join(DATA_DIR, model_dir, "statistics.json")
    stats = load_statistics(stats_file)

    input_tokens = [entry["input_tokens"] for entry in stats if "input_tokens" in entry]
    output_tokens = [
        entry["output_tokens"] for entry in stats if "output_tokens" in entry
    ]
    times = [entry["time_seconds"] for entry in stats if "time_seconds" in entry]

    input_avg, input_std = compute_stats(input_tokens)
    output_avg, output_std = compute_stats(output_tokens)
    time_avg, time_std = compute_stats(times)
    cost = compute_cost(input_tokens, output_tokens, model_dir)

    return {
        "model": model_dir,
        "avg_input_tokens": round(input_avg, 2),
        "std_input_tokens": round(input_std, 2),
        "avg_output_tokens": round(output_avg, 2),
        "std_output_tokens": round(output_std, 2),
        "avg_time_seconds": round(time_avg, 2),
        "std_time_seconds": round(time_std, 2),
        "estimated_cost_usd": cost,
    }


def main():
    model_dirs = find_model_dirs()

    all_stats = [summarize_model(d) for d in model_dirs]

    print("\nModel Summary with Estimated Costs (USD)\n")
    header = (
        f"{'Model':<25} | {'Avg Input':>10} | {'Std Input':>10} | "
        f"{'Avg Output':>11} | {'Std Output':>11} | {'Avg Time (s)':>12} | {'Std Time (s)':>12} | {'Est. Cost ($)':>13}"
    )
    print(header)
    print("-" * len(header))

    for s in all_stats:
        print(
            f"{s['model']:<25} | {s['avg_input_tokens']:>10} | {s['std_input_tokens']:>10} | "
            f"{s['avg_output_tokens']:>11} | {s['std_output_tokens']:>11} | "
            f"{s['avg_time_seconds']:>12} | {s['std_time_seconds']:>12} | "
            f"{s['estimated_cost_usd']:>13.4f}"
        )


if __name__ == "__main__":
    main()

