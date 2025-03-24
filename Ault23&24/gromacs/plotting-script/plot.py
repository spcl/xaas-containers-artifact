import os
import re
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
import argparse

colors = {"testcase0": "#6B6463", "testcase1": "#237CCC", "testcase2": "#067114", "testcase3": "#E10909", "testcase4": "#EF7934", "testcase5": "#5415F2", "testcase6": "#FFD62B"}  # Define colors for builds

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
            
            for run in range(11, 40):  # Runs from run11 to run40
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

def plot_legend(legends, colors):
    fig, ax = plt.subplots(figsize=(12, 6))
    handles = [plt.Line2D([0], [0], color=colors.get(key, 'gray'), lw=4) for key in legends]
    labels = list(legends.values())

    ax.legend(handles, labels, loc='center', ncol=1, frameon=False, prop={'size': 10})
    ax.axis('off')
    plt.tight_layout()
    plt.show()

def main():
    parser = argparse.ArgumentParser(description="Plot execution time and performance from GROMACS benchmarks.")
    parser.add_argument("input_directory", type=str, help="Path to the directory containing benchmark results")
    args = parser.parse_args()
    
    results = process_benchmark_data(args.input_directory)
    print(results)
    
    if results:
        plot_results(results)
        plot_legend(legends, colors)
    else:
        print("No valid data found for plotting.")

def plot_results(results):
    for testcase, builds in results.items():
        if not builds:
            continue

        labels = sorted(builds.keys(), key=lambda x: int(x.replace("testcase", "")))
        wall_means = [builds[k]['wall_time'][0] for k in labels]
        wall_errors = [builds[k]['wall_time'][1] for k in labels]
        perf_means = [builds[k]['performance'][0] for k in labels]
        perf_errors = [builds[k]['performance'][1] for k in labels]
        build_colors = [colors.get(build, "gray") for build in labels]
        xtick_labels = [f'Test case {int(x.replace("testcase", ""))}' for x in labels]

        # Side-by-side plots
        fig, axs = plt.subplots(1, 2, figsize=(18, 7), constrained_layout=True)

        # Execution Time
        axs[0].bar(labels, wall_means, yerr=wall_errors, capsize=5, color=build_colors, alpha=0.7)
        axs[0].set_title(f"GROMACS Execution Time for UEABS's {testcase} on Ault23", fontweight='bold')
        axs[0].set_ylabel("Execution Time (s)")
        axs[0].set_xticks(range(len(labels)))
        axs[0].set_xticklabels(xtick_labels, rotation=45, ha='right')

        # Performance
        axs[1].bar(labels, perf_means, yerr=perf_errors, capsize=5, color=build_colors, alpha=0.7)
        axs[1].set_title(f"GROMACS Performance for UEABS's for {testcase} Ault23", fontweight='bold')
        axs[1].set_ylabel("Performance (ns/day)")
        axs[1].set_xticks(range(len(labels)))
        axs[1].set_xticklabels(xtick_labels, rotation=45, ha='right')

        # Show the figure
        plt.show()

if __name__ == "__main__":
    legends = {
        "testcase0": "Test case 0: cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON",
        "testcase1": "Test case 1: cmake .. DGMX_SIMD=AVX2_256 -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=CUDA -DGMX_MPI=ON -DGMX_OPENMP=ON",
        "testcase2": "Test case 2: cmake .. DGMX_SIMD=AVX2_256 -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=CUDA -DGMX_MPI=ON -DGMX_OPENMP=ON (in Sarus)",
        "testcase3": "Test case 3: cmake .. DGMX_SIMD=AVX_512 -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=CUDA -DGMX_MPI=ON -DGMX_GPU_FFT_LIBRARY=cuFFT -DGMX_OPENMP=ON (in Sarus)",
        "testcase4": "Test case 4: spack install gromacs@2024.4 +mpi +cuda",
        "testcase5": "Test case 5: spack install gromacs@2024.4 +mpi +cuda cuda_arch=70 ^intel-oneapi-mkl ^fftw precision=float target=skylake_avx512",
        "testcase6": "Test case 6: cmake .. DGMX_SIMD=AVX_512 -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=CUDA -DGMX_MPI=ON -DGMX_OPENMP=ON "
    }
    main()