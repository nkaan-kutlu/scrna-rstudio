# ============================================================
# scRNA-seq + Spatial Transcriptomics RStudio Container
# Base: satijalab/seurat:latest
# Seurat + all its system dependencies (HDF5, Cairo, libpng,
# libmagick, libgdal, libgeos, libssl, etc.) are already
# solved in the base image. We only add on top.
# ============================================================

FROM satijalab/seurat:latest

USER root

# -----------------------------------------------------------
# Extra system libraries not covered by the Seurat base image
# -----------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgsl-dev \
    libglpk-dev \
    libfftw3-dev \
    libopenblas-dev \
    python3-pip \
    python3-dev \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------
# Python packages (single-cell analysis via reticulate)
# -----------------------------------------------------------
RUN pip3 install --no-cache-dir \
    scanpy \
    anndata \
    leidenalg \
    scvi-tools \
    squidpy \
    harmonypy \
    bbknn \
    scikit-misc \
    igraph \
    numpy \
    pandas \
    matplotlib \
    scipy \
    cellpose

# Tell reticulate where Python is
ENV RETICULATE_PYTHON=/usr/bin/python3

# -----------------------------------------------------------
# Bioconductor — single-cell core
# -----------------------------------------------------------
RUN R -e "BiocManager::install(c( \
    'SingleCellExperiment', \
    'scran', \
    'scater', \
    'scuttle', \
    'scDblFinder', \
    'DESeq2', \
    'edgeR', \
    'limma', \
    'glmGamPoi', \
    'ComplexHeatmap', \
    'clusterProfiler', \
    'enrichplot', \
    'org.Hs.eg.db', \
    'org.Mm.eg.db', \
    'AnnotationHub', \
    'GenomicRanges', \
    'BiocParallel' \
), ask=FALSE, update=FALSE)"

# -----------------------------------------------------------
# Bioconductor — spatial transcriptomics
# -----------------------------------------------------------
RUN R -e "BiocManager::install(c( \
    'SpatialExperiment', \
    'nnSVG', \
    'SPARK', \
    'Banksy', \
    'BayesSpace' \
), ask=FALSE, update=FALSE)"

# -----------------------------------------------------------
# Bioconductor — chromatin / multiome (Signac deps)
# -----------------------------------------------------------
RUN R -e "BiocManager::install(c( \
    'EnsDb.Hsapiens.v86', \
    'EnsDb.Mmusculus.v79', \
    'BSgenome.Hsapiens.UCSC.hg38', \
    'BSgenome.Mmusculus.UCSC.mm10', \
    'TFBSTools', \
    'JASPAR2020', \
    'motifmatchr', \
    'chromVAR' \
), ask=FALSE, update=FALSE)"

# -----------------------------------------------------------
# CRAN packages
# -----------------------------------------------------------
RUN R -e "install.packages(c( \
    'harmony', \
    'patchwork', \
    'viridis', \
    'viridisLite', \
    'pheatmap', \
    'ggrepel', \
    'cowplot', \
    'ggplot2', \
    'dplyr', \
    'tidyr', \
    'tibble', \
    'stringr', \
    'Matrix', \
    'irlba', \
    'RcppAnnoy', \
    'RANN', \
    'hdf5r', \
    'SeuratDisk', \
    'presto', \
    'DoubletFinder', \
    'lme4', \
    'broom', \
    'ggpubr', \
    'rstatix', \
    'circlize', \
    'ggalluvial', \
    'clustree', \
    'leiden', \
    'reticulate' \
), repos='https://cloud.r-project.org')"

# Signac (CRAN version)
RUN R -e "install.packages('Signac', repos='https://cloud.r-project.org')"

# -----------------------------------------------------------
# Verify key packages load (catches broken installs at build
# time rather than at runtime on TRUBA)
# -----------------------------------------------------------
RUN R -e "library(Seurat); library(harmony); library(scran); \
    library(SpatialExperiment); library(reticulate); \
    cat('All key packages load OK\n')"
