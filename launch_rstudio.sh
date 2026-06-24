#!/bin/bash
# ============================================================
# launch_rstudio.sh
# Run this in your TRUBA interactive desktop terminal.
# No module load, no path exports needed.
# ============================================================

SIF="$HOME/containers/scrna-rstudio.sif"

if [ ! -f "$SIF" ]; then
    echo "Container not found at $SIF"
    echo "Pull it first with:"
    echo "  apptainer pull $SIF docker://nkaankutlu/scrna-rstudio:latest"
    exit 1
fi

apptainer exec \
    --bind $HOME \
    --bind $SCRATCHDIR \
    "$SIF" \
    rstudio
