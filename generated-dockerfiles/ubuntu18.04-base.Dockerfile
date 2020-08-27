# RAPIDS Dockerfile for ubuntu18.04 "base" image
#
# base: RAPIDS is installed from published conda packages to the 'rapids' conda
# environment.
#
# Copyright (c) 2020, NVIDIA CORPORATION.

ARG CUDA_VER=10.1
ARG LINUX_VER=ubuntu18.04
ARG PYTHON_VER=3.7
ARG RAPIDS_VER=0.16
ARG FROM_IMAGE=gpuci/rapidsai

FROM ${FROM_IMAGE}:${RAPIDS_VER}-cuda${CUDA_VER}-base-${LINUX_VER}-py${PYTHON_VER}

ARG DASK_XGBOOST_VER=0.2*
ARG RAPIDS_VER=0.16*

ENV RAPIDS_DIR=/rapids
ENV LD_LIBRARY_PATH=/opt/conda/envs/rapids/lib:${LD_LIBRARY_PATH}

RUN mkdir -p ${RAPIDS_DIR}/utils 
COPY start_jupyter.sh nbtest.sh nbtestlog2junitxml.py ${RAPIDS_DIR}/utils/



RUN source activate rapids \
  && env \
  && conda info \
  && conda config --show-sources \
  && conda list --show-channel-urls
RUN gpuci_conda_retry install -y -n rapids \
  rapids=${RAPIDS_VER} 


RUN conda clean -afy \
  && chmod -R ugo+w /opt/conda ${RAPIDS_DIR}
WORKDIR ${RAPIDS_DIR}

COPY .run_in_rapids.sh /.run_in_rapids
ENTRYPOINT [ "/usr/bin/tini", "--", "/.run_in_rapids" ]

CMD [ "/bin/bash" ]