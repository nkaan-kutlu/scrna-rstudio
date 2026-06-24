# scRNA-seq + Spatial Transcriptomics RStudio Container

Docker image for single-cell and spatial transcriptomics analysis,
designed to run on the HPC system via Apptainer/Singularity.

Built on top of `satijalab/seurat:latest` so all system libraries
(HDF5, Cairo, libpng, libmagick, GDAL, etc.) are already solved.

## What's included

**R packages**
- Seurat 5 + SeuratDisk + Signac
- SingleCellExperiment, scran, scater, scuttle, scDblFinder
- DESeq2, edgeR, limma, glmGamPoi
- harmony, DoubletFinder, leiden, clustree
- SpatialExperiment, nnSVG, BayesSpace, Banksy
- clusterProfiler, ComplexHeatmap, enrichplot
- EnsDb (human + mouse), BSgenome (hg38 + mm10)
- chromVAR, JASPAR2020, motifmatchr (for ATAC/multiome)

**Python packages (via reticulate)**
- scanpy, anndata, scvi-tools, squidpy
- leidenalg, harmonypy, bbknn, cellpose

## How to use on TRUBA

### 1. Pull the image (do this once)
```bash
# Start an interactive compute session first
srun -N 1 -n 4 --mem=16G --time=02:00:00 --pty bash -l

export APPTAINER_CACHEDIR=$SCRATCHDIR/apptainer_cache
mkdir -p $APPTAINER_CACHEDIR $HOME/containers

apptainer pull $HOME/containers/scrna-rstudio.sif \
    docker://nkaankutlu/scrna-rstudio:latest
```

### 2. Create a launcher script
Save this as `~/launch_rstudio.sh`:
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
```

### 3. Use it (in your interactive desktop terminal)
```bash
~/launch_rstudio.sh
```
No `module load`, no path exports, no restarts.

## How to add a new package

1. Edit `Dockerfile` — add your package to the relevant `install.packages()` block
2. Commit and push with GitHub Desktop
3. GitHub Actions rebuilds automatically (only changed layers, ~5-15 min)
4. On TRUBA, re-pull: `apptainer pull --force $HOME/containers/scrna-rstudio.sif docker://nkaankutlu/scrna-rstudio:latest`
