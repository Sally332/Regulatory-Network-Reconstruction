#!/bin/bash
#SBATCH --job-name=ARACNe_Inference
#SBATCH --output=logs/aracne_inference_%A_%a.out
#SBATCH --error=logs/aracne_inference_%A_%a.err
#SBATCH --array=1-$(wc -l < data/TF_list.txt)
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00

# aracne_inference.sh
# ----------------------------------------------
# ARACNe Inference Job Array
# Each task processes one TF
# ----------------------------------------------

# Load environment (modules, variables)
module load R/4.0.5
module load java/1.8.0

TF_LIST="data/TF_list.txt"
TF=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$TF_LIST")  # Get TF for this array index

EXPR_MATRIX="$DATA_DIR/expression_matrix_01.txt"
CNA_MATRIX="$DATA_DIR/CNA_matrix.txt"   # or omit if not using
OUTPUT_ARACNE_DIR="$OUTPUT_DIR/aracne"
ARACNE_JAR="$ARACNE_JAR"

# Create TF-specific output directory
mkdir -p "$OUTPUT_ARACNE_DIR/$TF"

# Run ARACNe-AP for this TF (adjust parameters as needed)
java -Xmx8G -jar "$ARACNE_JAR" \
  -e "$EXPR_MATRIX" \
  -o "$OUTPUT_ARACNE_DIR/$TF" \
  -t "$TF" \
  --pvalue 1E-8 \
  --seed 1 \
  --calculateThreshold \
  --threads $SLURM_CPUS_PER_TASK

# Move output MI file to results folder (rename to include TF)
mv "$OUTPUT_ARACNE_DIR/$TF/"*MI* "$OUTPUT_ARACNE_DIR/${TF}_MI.txt"

# Clean up TF-specific folder
rm -rf "$OUTPUT_ARACNE_DIR/$TF"

# Log completion
echo "[ $(date) ] Completed ARACNe for TF: $TF" >> "$OUTPUT_DIR/logs/aracne_array.log"
