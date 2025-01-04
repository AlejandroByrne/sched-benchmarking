# !/usr/bin/bash

# ----------------------------
# benchmark_serial.sh
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

# Array of benchmark commands (each as a single process).
BENCHMARKS=(
    "stress-ng --cpu 1 --cpu-method matrixprod --timeout 10s"
    "stress-ng --cpu 1 --cpu-method fft --timeout 10s"
    "stress-ng --vm 1 --vm-bytes 512M --vm-method all --timeout 10s"
    "stress-ng --hdd 1 --hdd-bytes 1G --timeout 10s"
    "stress-ng --fork 1 --timeout 10s"
)

LOGFILE="benchmark_serial_results.log"
rm -f "$LOGFILE"

echo "Starting serial benchmarks..." | tee -a "$LOGFILE"

for cmd in "${BENCHMARKS[@]}"; do
    echo "Running: $cmd" | tee -a "$LOGFILE"
    /usr/bin/time -v bash -c "$cmd" 2>> "$LOGFILE"
    echo "------------------------------------" | tee -a "$LOGFILE"
done


echo "All benchmarks have completed." | tee -a "$LOGFILE"