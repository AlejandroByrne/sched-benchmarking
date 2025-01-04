#!/usr/bin/env bash

# ----------------------------
# benchmark_concurrent.sh
# ----------------------------

# Function to install stress-ng if it isn't found
install_stress_ng() {
    echo "stress-ng not found, attempting to install..."

    # Check which package manager is available
    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y stress-ng
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y stress-ng
    elif command -v yum &>/dev/null; then
        sudo yum install -y stress-ng
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y stress-ng
    else
        echo "Could not detect a supported package manager."
        echo "Please install 'stress-ng' manually and re-run this script."
        exit 1
    fi
}

# Check if stress-ng is available on the system
if ! command -v stress-ng &>/dev/null; then
    install_stress_ng
fi

# Benchmarks to run concurrently
BENCHMARKS=(
    "stress-ng --cpu 1 --cpu-method matrixprod --timeout 10s"
    "stress-ng --cpu 1 --cpu-method fft --timeout 10s"
    "stress-ng --vm 1 --vm-bytes 512M --vm-method all --timeout 10s"
    "stress-ng --hdd 1 --hdd-bytes 1G --timeout 10s"
    "stress-ng --fork 1 --timeout 10s"
)

LOGFILE="benchmark_concurrent_results.log"
rm -f "$LOGFILE"

echo "Starting concurrent benchmarks..." | tee -a "$LOGFILE"

# Record start time with sub-second precision
start_time="$(date +%s.%N)"

# Launch each benchmark in the background
for cmd in "${BENCHMARKS[@]}"; do
    echo "Launching in background: $cmd" | tee -a "$LOGFILE"
    bash -c "$cmd" &
done

# Wait for all background jobs to finish
wait

# Record end time
end_time="$(date +%s.%N)"

# Calculate elapsed time with "bc" for floating-point arithmetic
elapsed="$(echo "$end_time - $start_time" | bc -l)"

echo "All concurrent benchmarks have completed." | tee -a "$LOGFILE"

# Print elapsed time with higher resolution
echo "Total time for all tasks (concurrent): ${elapsed} seconds" | tee -a "$LOGFILE"
