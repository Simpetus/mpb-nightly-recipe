#!/bin/bash

anaconda -t $CONDA_UPLOAD_TOKEN upload -u chogan --label $1 $HOME/miniconda/conda-bld/**/mpb-*.tar.bz2 --force
