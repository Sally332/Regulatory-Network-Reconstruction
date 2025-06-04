#!/bin/bash

# post_processing.sh
# ----------------------------------------------
# Post-Processing Script: Merge, Enrich, Rank
# Usage: bash post_processing.sh --merge | --enrich | --rank
# ----------------------------------------------

# Load environment variables (if not already loaded)
module load R/4.0.5

OUTPUT_ARACNE_DIR="$OUTPUT_DIR/aracne"
OUT_PREFIX="$OUTPUT_DIR/network"
GWAS_LOCI="data/gwas_loci.txt"
GENE_SETS="data/gene_sets.gmt"

# Function: Merge MI files into single edge list
merge_edges() {
  echo "[ $(date) ] Merging MI files..." >> "$OUTPUT_DIR/logs/post_processing.log"
  header_file=$(ls "$OUTPUT_ARACNE_DIR" | grep "_MI.txt" | head -1)
  head -n 1 "$OUTPUT_ARACNE_DIR/$header_file" > "${OUT_PREFIX}_ARACNe_edges.txt"
  for file in "$OUTPUT_ARACNE_DIR"/*_MI.txt; do
    tail -n +2 "$file" >> "${OUT_PREFIX}_ARACNe_edges.txt"
  done
  echo "Merged edge list saved: ${OUT_PREFIX}_ARACNe_edges.txt" >> "$OUTPUT_DIR/logs/post_processing.log"
}

# Function: Run VSE (calls R script inline)
enrich_vse() {
  echo "[ $(date) ] Running VSE..." >> "$OUTPUT_DIR/logs/post_processing.log"
  Rscript - << 'EOF'
  library(data.table)
  edge_list <- fread("${OUT_PREFIX}_ARACNe_edges.txt", data.table=FALSE)
  gwas_genes <- fread("$GWAS_LOCI", header=FALSE, data.table=FALSE)[[1]]
  net_genes <- unique(edge_list$Target)
  overlap_flag <- net_genes %in% gwas_genes
  cont_table <- matrix(c(
    sum(overlap_flag),
    sum(!overlap_flag),
    sum(gwas_genes %in% net_genes == FALSE),
    length(unique(c(net_genes, gwas_genes))) - sum(overlap_flag) - sum(!overlap_flag) - sum(gwas_genes %in% net_genes == FALSE)
  ), nrow=2)
  res <- fisher.test(cont_table)
  out <- data.frame(OddsRatio=res$estimate, P.Value=res$p.value)
  fwrite(out, file="${OUT_PREFIX}_VSE_results.tsv", sep="\t")
EOF
  echo "VSE results saved: ${OUT_PREFIX}_VSE_results.tsv" >> "$OUTPUT_DIR/logs/post_processing.log"
}

# Function: Rank Master Regulators
rank_mr() {
  echo "[ $(date) ] Ranking Master Regulators..." >> "$OUTPUT_DIR/logs/post_processing.log"
  Rscript - << 'EOF'
  library(data.table)
  edge_list <- fread("${OUT_PREFIX}_ARACNe_edges.txt", data.table=FALSE)
  gwas_genes <- fread("$GWAS_LOCI", header=FALSE, data.table=FALSE)[[1]]
  tf_summary <- aggregate(MI ~ TF, data=edge_list, FUN=function(x) c(count=length(x), mean_MI=mean(x)))
  tf_summary$count <- sapply(tf_summary$MI, `[`, "count")
  tf_summary$mean_MI <- sapply(tf_summary$MI, `[`, "mean_MI")
  tf_summary$MI <- NULL
  tf_summary$GWAS_ovlp <- sapply(tf_summary$TF, function(tf) {
    targets <- edge_list$Target[edge_list$TF == tf]
    sum(targets %in% gwas_genes)
  })
  tf_summary$Score <- with(tf_summary, count * mean_MI + GWAS_ovlp)
  tf_ranked <- tf_summary[order(-tf_summary$Score), ]
  fwrite(tf_ranked, file="${OUT_PREFIX}_MR_ranking.tsv", sep="\t")
EOF
  echo "Master Regulator ranking saved: ${OUT_PREFIX}_MR_ranking.tsv" >> "$OUTPUT_DIR/logs/post_processing.log"
}

# Main
case "$1" in
  --merge)
    merge_edges
    ;;
  --enrich)
    enrich_vse
    ;;
  --rank)
    rank_mr
    ;;
  *)
    echo "Usage: $0 --merge | --enrich | --rank"
    exit 1
    ;;
esac
