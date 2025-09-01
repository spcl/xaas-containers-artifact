import os
import sys
import google.generativeai as genai

# Configure API key (set yours here or via environment variable)
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# Choose model
model_name = "gemini-2.0-flash-exp"
model = genai.GenerativeModel(model_name)

# Print model limits
model_info = genai.get_model(f"models/{model_name}")
print("Context window:", model_info.input_token_limit, "tokens")
print("Max output window:", model_info.output_token_limit, "tokens")


def count_tokens_with_gemini(text):
    try:
        token_count = model.count_tokens(text)
        return token_count.total_tokens
    except Exception as e:
        print(f"Error counting tokens: {e}")
        return 0


def read_text_file(filepath):
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            return f.read()
    except Exception as e:
        print(f"Failed to read {filepath}: {e}")
        return ""


def collect_token_counts(gromacs_path):
    token_report = {}
    cmake_tokens = 0
    docs_tokens = 0

    # CMakeLists.txt
    cmake_file = os.path.join(gromacs_path, "CMakeLists.txt")
    if os.path.exists(cmake_file):
        content = read_text_file(cmake_file)
        cmake_tokens = count_tokens_with_gemini(content)
        token_report["CMakeLists.txt"] = cmake_tokens
    else:
        print("CMakeLists.txt not found.")

    # docs/ folder
    # docs_dir = os.path.join(gromacs_path, "docs")
    docs_dir = os.path.join(gromacs_path, "cmake")
    if os.path.isdir(docs_dir):
        for root, _, files in os.walk(docs_dir):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, gromacs_path)
                content = read_text_file(full_path)
                count = count_tokens_with_gemini(content)
                token_report[rel_path] = count
                docs_tokens += count
    else:
        print("docs/ directory not found.")

    return token_report, cmake_tokens, docs_tokens


# === MAIN ===
if __name__ == "__main__":
    gromacs_path = sys.argv[1]
    report, cmake_tokens, docs_tokens = collect_token_counts(gromacs_path)

    print("\nToken Report:")
    for file, tokens in report.items():
        print(f"{file}: {tokens} tokens")

    print(f"\nTotal tokens in CMakeLists.txt: {cmake_tokens}")
    print(f"Total tokens in docs/ folder: {docs_tokens}")
    print(f"Combined total: {cmake_tokens + docs_tokens}")
