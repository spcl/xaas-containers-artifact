import argparse
import os
import json
import time
import google.generativeai as genai


class GeminiInterface:
    PROMPTS = {
        "default": """

    I will share a build file, and I would like you to identify all the specialization points for an HPC program and the associated build flags used to enable those features during the build process. Please pay close attention to:

    - Comments and messages within the build file, as they often reveal the necessary flags.
    - Functions like `gmx_option_multichoice`, which specify build flags and options for libraries.
    - Ensure libraries are correctly matched to their corresponding build flags based on these functions.
    - Option Commands: In some projects, build flags are provided in `option` commands. Look at these commands to extract the build flags correctly.
    - Full Build Flags Extraction: Ensure that the full build flags are extracted, not just partial representations. For instance, if a flag is defined as `-DQE_ENABLE_CUDA=ON`, extract the entire flag with its value.
    - Distinguish Between Build Flags and Preprocessor Definitions: Do not confuse preprocessor definitions (e.g., `__CUDA`, `__MPI`) with actual build flags (e.g., `-DQE_ENABLE_CUDA`, `-DQE_ENABLE_MPI`). Extract only the build flags that are explicitly defined in the build configuration.
    - Portability Frameworks: Some build systems use portability frameworks like Kokkos. Pay attention to build flags like `-DKokkos_ENABLE_OPENMP`, `-DKokkos_ENABLE_PTHREAD`, and `-DKokkos_ENABLE_CUDA`.
    - Vectorization Libraries: Some projects use external vectorization libraries like V4. Look for build flags such as `-DUSE_V4_ALTIVEC`, `-DUSE_V4_PORTABLE`, and `-DUSE_V4_SSE`.

    Key Instructions:
    1. Analyze Functions for Build Flags:
    - Look for functions such as `gmx_option_multichoice`, `gmx_dependent_option`, and `option` commands that define build flags and their corresponding options.
    - For example, the flag `-DGMX_FFT_LIBRARY` has options like `fftw3`, `mkl`, and `fftpack[built-in]`.
    - Another example is `-DGMX_GPU_FFT_LIBRARY` with options like `cuFFT`, `VkFFT`, `clFFT`, `rocFFT`, and `MKL`. Match the library names with the build flags from these function calls.
    - Additionally, the flag `-DGMX_GPU` has options like `CUDA`, `OpenCL`, `SYCL`, and `HIP`. Ensure these GPU backends are matched correctly to their corresponding flags.
    - For Kokkos, look for flags like `-DKokkos_ENABLE_OPENMP`, `-DKokkos_ENABLE_PTHREAD`, and `-DKokkos_ENABLE_CUDA`.

    2. Match Libraries to Flags:
    - Libraries should be matched to their respective build flags based on these function definitions.
    - For example:
        - If `GMX_FFT_LIBRARY` is set to `fftw3`, the build flag is `-DGMX_FFT_LIBRARY=fftw3`.
        - If `GMX_GPU_FFT_LIBRARY` is set to `cuFFT`, the build flag is `-DGMX_GPU_FFT_LIBRARY=cuFFT`.
        - For vectorization, look for flags like `-DUSE_V4_ALTIVEC`, `-DUSE_V4_PORTABLE`, and `-DUSE_V4_SSE`.

    3. Match GPU Backends to GMX_GPU:
    - Ensure that GPU backends (CUDA, OpenCL, SYCL, HIP, METAL) are matched to the `GMX_GPU` flag based on the `gmx_option_multichoice` function.
    - For example:
        - If `GMX_GPU` is set to `CUDA`, the build flag is `-DGMX_GPU=CUDA`.
        - If `GMX_GPU` is set to `SYCL`, the build flag is `-DGMX_GPU=SYCL`.
    - For Quantum ESPRESSO: Ensure that GPU backends like CUDA are matched to their corresponding build flags, such as `-DQE_ENABLE_CUDA`, instead of preprocessor definitions like `__CUDA`.

    4. Consider Default Values and Dependencies:
    - Identify the default libraries and how they are conditionally set. For example:
        - `GMX_FFT_LIBRARY_DEFAULT` is `mkl` if `GMX_INTEL_LLVM` is set, otherwise `fftw3`.
        - The GPU FFT library defaults vary based on the GPU backend (e.g., `cuFFT` for CUDA, `VkFFT` for OpenCL).

    5. Special Attention to FFT Libraries:
    - Look for all flags related to FFT libraries like:
        - `-DGMX_FFT_LIBRARY`
        - `-DGMX_FFT_LIBRARY_DEFAULT`
        - `-DGMX_GPU_FFT_LIBRARY`
    - Extract not only the flag but also the corresponding library it enables (e.g., `fftw3`, `mkl`, `cuFFT`).

    6. Include Relevant Build Flags:
    - Do not include preprocessor definitions generated internally. Only include build flags explicitly defined in the file.
    - Ensure that each build flag is extracted with its full definition, including any assigned values.

    Specifically, identify the following:

    - Does the build system support GPU builds? (For example, the presence of a flag like BUILD_GPU indicates GPU support.)
    - What GPU backends does it support (e.g. CUDA, HIP, SYCL, OpenCL)? Are these backends enabled or disabled by default? What is their minimum version, if specified?
    - What parallel programming libraries (e.g. MPI, OpenMP, Pthread, thread-MPI, OpenACC) are supported, and are they enabled or disabled by default? What is their minimum version, if specified?
    - What linear algebra libraries (e.g. BLAS, LAPACK, SCALAPACK, MKL/oneMKL) does the build system use, and under which conditions? What are the default libraries used in the build process?
    - What Fast Fourier Transform libraries (e.g. FFTW, fftpack, MKL/oneMKL, cuFFT, vkFFT, clFFT, rocFFT) does the build system use? What library is built-in? Are there specific dependencies for the library to be used (for example, they must be used with a certain GPU backend or parallel library)? Are they enabled or disabled by default? For the build-flags, look for flags defined via `gmx_option_multichoice` such as `-DGMX_FFT_LIBRARY`, `-DGMX_FFT_LIBRARY_DEFAULT`, `-DGMX_GPU_FFT_LIBRARY`.
    - What other external libraries are used, what versions are specified, and what are their dependencies? List all external libraries and the conditions for their use.
    - What other compiler flags are supported?
    - Are there build flags used to optimize the performance of the program? (e.g., auto-tuning, team reduction, hierarchical parallelism, accumulators, qunatization, batch size, force use of custom matrix multiplications)
    - Which compilers are supported, and what are the minimum versions required?
    - What architectures does the system support?
    - Does it support SIMD vectorization, and what vectorization levels are supported? find the build flag for each supported vectorization level.
    - What is the minimum version required for the build system? Is it a CMake or Make build system?
    - Are there any libraries that require internal builds? If so, name them and provide the build flags (e.g. `-DGMX_BUILD_OWN_FFTW`, `DBUILD_INTERNAL_KOKKOS`).

    The answer should be provided as a JSON structure adhering to the specified schema, with keys including `gpu_build`, `gpu_backends`, `parallel_programming_libraries`, `linear_algebra_libraries`, `fft_libraries`, `other_external_libraries`, `optimization_build_flags`, `compiler_flags`, `compilers`, `architectures`, `simd_vectorization`, and `build_system`, `internal_build`. The `build_flag` value for each feature should be the flag itself (e.g., `-DGMX_SIMD`, `-DGMX_GPU`, `-DQE_ENABLE_CUDA`, `-DQE_ENABLE_MPI`, `-DKokkos_ENABLE_OPENMP`, `-DUSE_V4_ALTIVEC`) without any surrounding text. Do not include any preprocessor definitions that are generated internally. The response must be a valid JSON structure; do not include any introductory or explanatory text.

    Here is the build file:
    {file_content}

    JSON output schema. Use this JSON schema to format your response but do not include it in the output:
    {schema}
    """
    }

    def __init__(self):
        self.api_key = os.environ.get("GOOGLE_API_KEY")
        if not self.api_key:
            raise EnvironmentError(
                "Error: GOOGLE_API_KEY environment variable not set."
            )

        self.schema = self.load_json_schema()

    def load_json_schema(self):
        schema_path = os.path.join(os.path.abspath("."), "json_schema.json")
        with open(schema_path, "r") as f:
            return json.load(f)

    def read_file(self, filepath):
        with open(filepath, "r", encoding="utf-8") as f:
            return f.read()

    def find_build_files(self, directory):
        paths = []
        for entry in os.listdir(directory):
            if entry.casefold() in ["cmakelists.txt", "cmakelists_ggml.txt"]:
                paths.append(os.path.join(directory, entry))
        if paths:
            return paths
        raise FileNotFoundError("CMakeLists.txt not found in the project directory.")


class SpecializationBatchExtractor:
    def __init__(
        self, project_dir, output_dir="gemini-flash-1.5", model_name="gemini-1.5-flash"
    ):
        self.project_dir = os.path.abspath(project_dir)
        self.output_dir = output_dir
        self.model_name = model_name
        self.helper = GeminiInterface()

        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)

        genai.configure(api_key=self.helper.api_key)
        self.model = genai.GenerativeModel(model_name)

    def get_prompt(self):
        cmake_paths = self.helper.find_build_files(self.project_dir)
        file_contents = ""
        for file in cmake_paths:
            file_contents += self.helper.read_file(file) + "\n\n"
        return self.helper.PROMPTS["default"].format(
            schema=json.dumps(self.helper.schema), file_content=file_contents
        )

    def run(self, num_runs=10):
        prompt = self.get_prompt()
        stats = []

        for i in range(1, num_runs + 1):
            start_time = time.time()
            response = self.model.generate_content(prompt)
            elapsed_time = time.time() - start_time

            response_text = response.text.strip()
            if response_text.startswith("```json"):
                response_text = response_text.split("\n", 1)[1]
            if response_text.endswith("```"):
                response_text = response_text.rsplit("\n", 1)[0]

            try:
                parsed_json = json.loads(response_text)
            except json.JSONDecodeError:
                parsed_json = {"error": "Invalid JSON", "raw_response": response_text}

            output_file = os.path.join(
                self.output_dir, f"specialization_point_{i}.json"
            )
            with open(output_file, "w") as f:
                json.dump(parsed_json, f, indent=2)

            stats.append(
                {
                    "iteration": i,
                    "input_tokens": response.usage_metadata.prompt_token_count,
                    "output_tokens": response.usage_metadata.candidates_token_count,
                    "time_seconds": elapsed_time,
                }
            )

        stats_path = os.path.join(self.output_dir, "statistics.json")
        with open(stats_path, "w") as f:
            json.dump(stats, f, indent=2)

        return stats


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-n",
        "--num-runs",
        type=int,
        default=1,
    )

    parser.add_argument(
        "-m",
        "--model-name",
        type=str,
        required=True,
    )

    parser.add_argument(
        "-o",
        "--output-dir",
        type=str,
        required=True,
    )

    args = parser.parse_args()

    project_directory = "."  # Assumes the script is run in the project directory
    extractor = SpecializationBatchExtractor(
        project_directory, model_name=args.model_name, output_dir=args.output_dir
    )
    stats = extractor.run(num_runs=args.num_runs)

    print("--- Run Statistics ---")
    for s in stats:
        print(s)
