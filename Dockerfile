# ============================================================
# scRNA-seq + Spatial Transcriptomics RStudio Container
# Base: satijalab/seurat:latest
# ============================================================

FROM satijalab/seurat:latest

USER root

# -----------------------------------------------------------
# Check what R version and Bioconductor we're working with
# -----------------------------------------------------------
RUN R -e "R.version; BiocManager::version()"

# -----------------------------------------------------------
# Extra system libraries
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
# Python virtual environment
# -----------------------------------------------------------
ENV VENV=/opt/scrna-venv
RUN python3 -m venv $VENV
ENV PATH="$VENV/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
    "numpy<2.0" \
    "pandas>=1.5" \
    scipy \
    matplotlib \
    scikit-learn

RUN pip install --no-cache-dir \
    anndata \
    igraph \
    leidenalg

RUN pip install --no-cache-dir scanpy

RUN pip install --no-cache-dir \
    squidpy \
    harmonypy \
    bbknn \
    scikit-misc

RUN pip install --no-cache-dir scvi-tools

RUN pip install --no-cache-dir cellpose

ENV RETICULATE_PYTHON="$VENV/bin/python"

# -----------------------------------------------------------
# Bioconductor — install each package individually so a single
# failure does not abort the entire layer
# -----------------------------------------------------------

RUN R -e "BiocManager::install('SingleCellExperiment', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('scran',                ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('scater',               ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('scuttle',              ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('scDblFinder',          ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('DESeq2',               ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('edgeR',                ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('limma',                ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('glmGamPoi',            ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('ComplexHeatmap',       ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('clusterProfiler',      ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('enrichplot',           ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('org.Hs.eg.db',         ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('org.Mm.eg.db',         ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('AnnotationHub',        ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('GenomicRanges',        ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('BiocParallel',         ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('SpatialExperiment',    ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('nnSVG',                ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('BayesSpace',           ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('EnsDb.Hsapiens.v86',   ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('EnsDb.Mmusculus.v79',  ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('TFBSTools',            ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('JASPAR2020',           ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('motifmatchr',          ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('chromVAR',             ask=FALSE, update=FALSE)"

# Large genome packages — each is ~700 MB, separate layers
RUN R -e "BiocManager::install('BSgenome.Hsapiens.UCSC.hg38', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('BSgenome.Mmusculus.UCSC.mm10', ask=FALSE, update=FALSE)"

# -----------------------------------------------------------
# CRAN packages
# -----------------------------------------------------------
RUN R -e "install.packages(c( \
    'harmony', 'patchwork', 'viridis', 'viridisLite', \
    'pheatmap', 'ggrepel', 'cowplot', 'ggplot2', \
    'dplyr', 'tidyr', 'tibble', 'stringr' \
), repos='https://cloud.r-project.org')"

RUN R -e "install.packages(c( \
    'Matrix', 'irlba', 'RcppAnnoy', 'RANN', \
    'hdf5r', 'presto', 'lme4', 'broom' \
), repos='https://cloud.r-project.org')"

RUN R -e "install.packages(c( \
    'ggpubr', 'rstatix', 'circlize', 'ggalluvial', \
    'clustree', 'leiden', 'reticulate' \
), repos='https://cloud.r-project.org')"

RUN R -e "install.packages('SeuratDisk', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('DoubletFinder', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('Signac', repos='https://cloud.r-project.org')"

# -----------------------------------------------------------
# Visualization — ggplot2 extensions & plot utilities
# -----------------------------------------------------------
RUN R -e "install.packages(c( \
    'ggforce', 'ggfun', 'ggnewscale', 'ggridges', \
    'ggdensity', 'ggExtra', 'ggplotify', 'ggthemes', \
    'ggsci', 'RColorBrewer', 'paletteer', 'scales', \
    'colorspace', 'gridExtra' \
), repos='https://cloud.r-project.org')"

# Spatial visualization (Bioconductor)
RUN R -e "BiocManager::install('ggspavis', ask=FALSE, update=FALSE)"

# Interactive / export
RUN R -e "install.packages(c( \
    'plotly', 'htmlwidgets', 'svglite', 'Cairo' \
), repos='https://cloud.r-project.org')"

# Heatmap alternatives
RUN R -e "install.packages('superheat', repos='https://cloud.r-project.org')"

# -----------------------------------------------------------
# Data manipulation & workflow utilities
# -----------------------------------------------------------
RUN R -e "install.packages(c( \
    'data.table', 'purrr', 'forcats', \
    'lubridate', 'glue', 'janitor', \
    'readxl', 'writexl', 'openxlsx' \
), repos='https://cloud.r-project.org')"

# -----------------------------------------------------------
# Cell type annotation
# -----------------------------------------------------------
RUN R -e "BiocManager::install('SingleR', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('celldex', ask=FALSE, update=FALSE)"
