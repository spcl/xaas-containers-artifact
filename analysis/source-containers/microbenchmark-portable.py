import os
import re
import numpy as np
import scipy.stats as stats
import pandas as pd

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))

DATA_DIR = os.path.join(
    CURRENT_DIR, os.path.pardir, os.path.pardir, "benchmarks-source", "gromacs"
)

mapping_experiments = {
    "testcase0": "xaas",
    "testcase1": "sycl_portable",
    "testcase2": "sycl_portable_intel",
}

STEPS = [20000, 50000]


def extract_values(md_log_path):
    wall_time, performance, io_time = None, None, None
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
                if "Write traj." in line:
                    io_time = line.split()[5]
                if wall_time and performance and io_time:
                    break
    except Exception as e:
        print(f"Error reading {md_log_path}: {e}")
    if wall_time is None or performance is None or io_time is None:
        print(f"Missing data in {md_log_path}")
        # raise RuntimeError()
    return wall_time, performance, io_time


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

    system_path = os.path.join(
        gromacs_path, "microbenchmark-portable", "gromacs-benchmarks"
    )

    test_case_letter = "A"

    benchmarks_path = os.path.join(
        system_path, f"Testcase{test_case_letter}_benchmarks-portable"
    )

    for testcase in os.listdir(benchmarks_path):
        print(f"Processing {testcase}")
        testcase_path = os.path.join(benchmarks_path, testcase)

        for steps in STEPS:
            full_testcase_path = os.path.join(testcase_path, f"steps_{steps}")

            testcase_name = testcase.split("_")[1]
            system = testcase.split("_")[2]

            wall_times = []
            performances = []
            io_times = []
            for run_dir in os.listdir(full_testcase_path):
                run_path = os.path.join(full_testcase_path, run_dir, "md.log")
                if os.path.exists(run_path):
                    wall, perf, io_time = extract_values(run_path)
                    if wall is not None and perf is not None:
                        wall_times.append(wall)
                        performances.append(perf)
                        io_times.append(io_time)

            print(
                f"Processing {system} - {test_case_letter} - {testcase_path}, samples: {len(wall_times)}, {len(performances)}"
            )

            if wall_times and performances:
                for i in range(len(wall_times)):
                    wall_times[i] -= float(io_times[i])

                wall_mean, wall_ci = compute_statistics(wall_times, harmonic=False)
                perf_hmean, perf_ci = compute_statistics(performances, harmonic=True)

                print(
                    f"Processing {system} - {testcase_name}, time: {wall_mean} +- {wall_ci}"
                )

                for time in wall_times:
                    records.append(
                        {
                            "System": system,
                            "TestCase": mapping_experiments[testcase_name],
                            "Benchmark": test_case_letter,
                            "Metric": "Execution Time",
                            "Mean": time,
                            "Steps": steps,
                            # "CI": wall_ci,
                        }
                    )

    return pd.DataFrame(records)


df = process_data(DATA_DIR)

summary = df.groupby(["System", "TestCase", "Steps"])["Mean"].mean().reset_index()
print(summary)

for system in ["ault23", "ault25"]:
    for steps in [20000, 50000]:
        sycl = summary.loc[
            (summary["System"] == system)
            & (summary["Steps"] == steps)
            & (summary["TestCase"] == "sycl_portable"),
            "Mean",
        ].values[0]

        sycl_intel = summary.loc[
            (summary["System"] == system)
            & (summary["Steps"] == steps)
            & (summary["TestCase"] == "sycl_portable_intel"),
            "Mean",
        ].values[0]

        xaas = summary.loc[
            (summary.System == system)
            & (summary.Steps == steps)
            & (summary.TestCase == "xaas"),
            "Mean",
        ].values[0]

        print("SYCL w/o Intel", system, steps, sycl, xaas, sycl / xaas * 100)
        print("SYCL w/ Intel", system, steps, sycl_intel, xaas, sycl_intel / xaas * 100)
