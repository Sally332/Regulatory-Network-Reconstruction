# Gene Regulatory Network Reconstruction Pipeline

## Biological Context
GWAS and transcriptomic studies reveal that many disease‐associated loci influence gene regulation. In cancer and other complex diseases, pinpointing which transcription factors (TFs) drive aberrant gene expression can uncover biomarkers and therapeutic targets. This pipeline uses **ARACNe** to infer TF–target networks from bulk RNA‐seq, single‐cell pseudo‐bulk, or spatial transcriptomics data (optionally adjusting for copy‐number alterations), and integrates GWAS loci via Variant Set Enrichment (VSE) to prioritize master regulators.

## Analysis Purposes
- **Bulk RNA‐seq**: Infer TF–target interactions in tissues (e.g., tumor vs. normal).  
- **Single‐Cell RNA‐seq**: Build pseudo‐bulk or cell‐type–specific networks to capture cellular heterogeneity.  
- **Spatial Transcriptomics**: Map regulatory modules onto tissue structure to identify region‐specific circuits.  
- **GWAS Integration**: Use Variant Set Enrichment (VSE) to check if network genes overlap GWAS‐identified loci, highlighting modules linked to disease risk.  
- **Master Regulator Ranking**: Rank transcription factors based on their number of targets, average mutual information, and overlap with GWAS genes to identify top regulatory drivers.

## Key Steps
- **Data Loading & Preprocessing**  
- **Mutual Information Calculation (ARACNe)**  
- **Edge List Generation**  
- **Variant Set Enrichment (VSE)**  
- **Master Regulator Ranking**  
- **Logging & Reporting** 

For full details on each step, see the **README** (docs/README.pdf) and **HPC instructions** in `hpc/`.

## Contact & License
Author: Sally Yepes (sallyepes233@gmail.com)
License: MIT


