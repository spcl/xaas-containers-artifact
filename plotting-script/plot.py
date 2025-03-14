import os
import re
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
import argparse

def extract_values(md_log_path):
    wall_time = None
    performance = None
    try:
        with open(md_log_path, 'r') as file:
            lines = file.readlines()
            for i in range(len(lines)):
                if "Time:" in lines[i]:
                    time_values = re.findall(r'\d+\.\d+', lines[i])
                    if len(time_values) >= 2:
                        wall_time = float(time_values[1])  # Extracting the second value (Wall time)
                if "Performance:" in lines[i]:
                    perf_values = re.findall(r'\d+\.\d+', lines[i])
                    if len(perf_values) >= 1:
                        performance = float(perf_values[0])
                
                if wall_time is not None and performance is not None:
                    break
    except Exception as e:
        print(f"Error reading {md_log_path}: {e}")
    
    return wall_time, performance

def compute_statistics(data, harmonic=False):
    if len(data) == 0:
        return None, None
    
    if harmonic:
        mean_value = stats.hmean(data)
    else:
        mean_value = np.mean(data)
    
    confidence = stats.t.interval(0.95, len(data)-1, loc=mean_value, scale=stats.sem(data)) if len(data) > 1 else (mean_value, mean_value)
    error = (confidence[1] - confidence[0]) / 2 if len(data) > 1 else 0
    
    return mean_value, error

def process_benchmark_data(input_directory):
    results = {}
    
    for testcase in ['TestcaseA_benchmarks', 'TestcaseB_benchmarks']:
        testcase_path = os.path.join(input_directory, testcase)
        if not os.path.exists(testcase_path):
            continue
        
        testcase_name = re.sub(r'_benchmarks$', '', testcase).replace("Testcase", "Test Case ")
        results[testcase_name] = {}
        
        for build in os.listdir(testcase_path):
            build_path = os.path.join(testcase_path, build)
            if not os.path.isdir(build_path):
                continue
            
            match = re.search(r'gromacs_(testcase\d+)_', build)
            build_name = match.group(1) if match else build
            
            wall_times = []
            performances = []
            
            for run in range(11, 31):  # Runs from run11 to run30
                run_path = os.path.join(build_path, f'run{run}', 'md.log')
                if os.path.exists(run_path):
                    wall_time, performance = extract_values(run_path)
                    if wall_time is not None and performance is not None:
                        wall_times.append(wall_time)
                        performances.append(performance)
            
            if wall_times and performances:
                wall_time_mean, wall_time_ci = compute_statistics(wall_times)
                performance_hmean, performance_ci = compute_statistics(performances, harmonic=True)
                results[testcase_name][build_name] = {
                    "wall_time": (wall_time_mean, wall_time_ci),
                    "performance": (performance_hmean, performance_ci)
                }
    
    return results

def main():
    parser = argparse.ArgumentParser(description="Plot execution time and performance from GROMACS benchmarks.")
    parser.add_argument("input_directory", type=str, help="Path to the directory containing benchmark results")
    args = parser.parse_args()
    
    results = process_benchmark_data(args.input_directory)
    print(results)
    
    if results:
        plot_results(results)
    else:
        print("No valid data found for plotting.")

def plot_results(results):
    colors = {"testcase0": "k", "testcase1": "b", "testcase2": "r", "testcase3": "g", "testcase4": "y", "testcase5": "c"}  

    
    for testcase, builds in results.items():
        if not builds:
            continue
        
        labels = sorted(builds.keys(), key=lambda x: int(x.replace("testcase", ""))) 
        wall_means = [builds[k]['wall_time'][0] for k in labels]
        wall_errors = [builds[k]['wall_time'][1] for k in labels]
        perf_means = [builds[k]['performance'][0] for k in labels]
        perf_errors = [builds[k]['performance'][1] for k in labels]
        
        build_colors = [colors.get(build, "gray") for build in labels]
        
        plt.figure(figsize=(12, 7))
        plt.bar(labels, wall_means, yerr=wall_errors, capsize=5, color=build_colors, alpha=0.7)
        plt.xticks(rotation=45, ha='right')
        plt.xlabel("Build Configuration")
        plt.ylabel("Execution Time (s)")
        plt.title(f"Execution Time for {testcase}", fontweight='bold')
        plt.tight_layout()
        plt.show()
        
        plt.figure(figsize=(12, 7))
        plt.bar(labels, perf_means, yerr=perf_errors, capsize=5, color=build_colors, alpha=0.7)
        plt.xticks(rotation=45, ha='right')
        plt.xlabel("Build Configuration")
        plt.ylabel("Performance (ns/day)")
        plt.title(f"Performance for {testcase}", fontweight='bold')
        plt.tight_layout()
        plt.show()

if __name__ == "__main__":
    main()
