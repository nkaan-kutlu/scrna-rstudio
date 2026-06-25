# scRNA-seq & Spatial Transcriptomics Container

A portable, reproducible Docker/Apptainer container for single-cell RNA sequencing and spatial transcriptomics analysis. Built on top of [`satijalab/seurat`](https://hub.docker.com/r/satijalab/seurat) so all system-level dependencies (HDF5, Cairo, libpng, libmagick, GDAL, etc.) are pre-solved — no manual library compilation required.

[![Docker Hub](https://img.shields.io/docker/pulls/nkaankutlu/scrna-rstudio)](https://hub.docker.com/r/nkaankutlu/scrna-rstudio)
[![Build](https://github.com/nkaan-kutlu/scrna-rstudio/actions/workflows/build.yml/badge.svg)](https://github.com/nkaan-kutlu/scrna-rstudio/actions/workflows/build.yml)

---

## Contents

- [What's included](#whats-included)
- [Usage — Local machine (Docker)](#usage--local-machine-docker)
- [Usage — HPC with Apptainer/Singularity](#usage--hpc-with-apptainersingularity)
- [Usage — TRUBA HPC (Turkey)](#usage--truba-hpc-turkey)
- [Adding packages](#adding-packages)
- [Citation](#citation)

---

## What's included

### R packages

| Category | Packages |
|---|---|
| **Single-cell core** | Seurat 5, SeuratDisk, SingleCellExperiment, scran, scater, scuttle, scDblFinder |
| **Differential expression** | DESeq2, edgeR, limma, glmGamPoi |
| **Integration & clustering** | harmony, leiden, clustree, DoubletFinder |
| **Spatial transcriptomics** | SpatialExperiment, ggspavis, nnSVG, BayesSpace |
| **Chromatin / multiome** | Signac, chromVAR, motifmatchr, JASPAR2020, TFBSTools |
| **Cell type annotation** | SingleR, celldex |
| **Pathway analysis** | clusterProfiler, enrichplot, org.Hs.eg.db, org.Mm.eg.db |
| **Genome references** | EnsDb.Hsapiens.v86, EnsDb.Mmusculus.v79, BSgenome hg38 + mm10 |
| **Visualization** | ggplot2, patchwork, ComplexHeatmap, pheatmap, superheat, ggridges, ggnewscale, ggforce, plotly, viridis, paletteer, RColorBrewer, ggsci, cowplot, ggrepel, ggpubr |
| **Data manipulation** | tidyverse, data.table, dplyr, purrr, janitor, readxl, openxlsx |

### Python packages (accessible via `reticulate`)

scanpy, anndata, scvi-tools, squidpy, cellpose, leidenalg, harmonypy, bbknn

---

## Usage — Local machine (Docker)

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

### Run RStudio in your browser
```bash
docker run --rm \
    -p 8787:8787 \
    -e PASSWORD=yourpassword \
    -v /path/to/your/data:/home/rstudio/data \
    nkaankutlu/scrna-rstudio:latest
```

Then open `http://localhost:8787` in your browser.
- Username: `rstudio`
- Password: whatever you set above

Replace `/path/to/your/data` with the folder on your machine containing your data files — it will appear under `~/data` inside RStudio.

### Run with GPU support (NVIDIA)
```bash
docker run --rm \
    --gpus all \
    -p 8787:8787 \
    -e PASSWORD=yourpassword \
    -v /path/to/your/data:/home/rstudio/data \
    nkaankutlu/scrna-rstudio:latest
```

---

## Usage — HPC with Apptainer/Singularity

Most HPC systems support [Apptainer](https://apptainer.org/) (formerly Singularity) and can pull Docker images directly.

### Pull the image (do once)
```bash
# Set cache to scratch space to avoid home directory quota issues
export APPTAINER_CACHEDIR=/scratch/$USER/apptainer_cache
mkdir -p $APPTAINER_CACHEDIR $HOME/containers

apptainer pull $HOME/containers/scrna-rstudio.sif \
    docker://nkaankutlu/scrna-rstudio:latest
```

### Run RStudio
```bash
apptainer exec \
    --bind $HOME \
    --bind /scratch/$USER \
    $HOME/containers/scrna-rstudio.sif \
    rstudio
```

### Run a script non-interactively
```bash
apptainer exec \
    --bind $HOME \
    $HOME/containers/scrna-rstudio.sif \
    Rscript /path/to/your/analysis.R
```

### Submit as a SLURM batch job
```bash
#!/bin/bash
#SBATCH --job-name=scrna-analysis
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=08:00:00

apptainer exec \
    --bind $HOME \
    --bind /scratch/$USER \
    $HOME/containers/scrna-rstudio.sif \
    Rscript $HOME/scripts/my_analysis.R
```

---

## Usage — TRUBA HPC (Turkey)

TRUBA uses Apptainer. Pull the image on a compute node (not the login node):

```bash
# Start an interactive compute session first
srun -N 1 -n 4 --mem=16G --time=02:00:00 --pty bash -l

export APPTAINER_CACHEDIR=$SCRATCHDIR/apptainer_cache
mkdir -p $APPTAINER_CACHEDIR $HOME/containers

apptainer pull $HOME/containers/scrna-rstudio.sif \
    docker://nkaankutlu/scrna-rstudio:latest
```

### Launcher script for interactive desktop

Save this as `~/launch_rstudio.sh` and run it from your TRUBA interactive desktop terminal:

```bash
#!/bin/bash
apptainer exec \
    --bind $HOME \
    --bind $SCRATCHDIR \
    $HOME/containers/scrna-rstudio.sif \
    rstudio
```

```bash
chmod +x ~/launch_rstudio.sh
~/launch_rstudio.sh
```

No `module load`, no path exports, no restarts needed when installing new packages.

---

## Adding packages

### Temporary (current session only)
Inside RStudio, install as normal — packages will be available until the container session ends:
```r
install.packages("newpackage")
```

### Permanent (baked into the image)
1. Fork this repository or edit the `Dockerfile` directly on GitHub
2. Add your package to the relevant `RUN R -e "install.packages(...)"` block
3. Commit — GitHub Actions will automatically rebuild and push to Docker Hub
4. Re-pull the updated `.sif` on your HPC:
```bash
apptainer pull --force $HOME/containers/scrna-rstudio.sif \
    docker://nkaankutlu/scrna-rstudio:latest
```

---