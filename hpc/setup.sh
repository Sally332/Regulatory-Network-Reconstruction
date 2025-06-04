#!/bin/bash

# setup.sh
# ----------------------------------------------
# Environment Setup for HPC Jobs
# ----------------------------------------------

# 1. Load required modules (example: R, Java)
module load R/4.0.5
module load java/1.8.0

# 2. (Optional) Activate conda environment with ARACNe-AP and R packages
# source activate grn_env

# 3. Define environment variables
export DATA_DIR="$(pwd)/data"           # Path to data directory
export OUTPUT_DIR="$(pwd)/results"      # Path to results directory
export ARACNE_JAR="/path/to/ARACNe.jar" # Path to ARACNe-AP JAR

# 4. Verify directories exist
mkdir -p "$OUTPUT_DIR/aracne"
mkdir -p "$OUTPUT_DIR/logs"

echo "[ $(date) ] Environment setup complete." > "$OUTPUT_DIR/logs/setup.log"
