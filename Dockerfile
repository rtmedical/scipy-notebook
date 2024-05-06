# Copyright (c) The Jupyter Development Team.
# Distributed under the Modified BSD License.

ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook
FROM $BASE_CONTAINER

ARG CONDA_DIR=/opt/conda
ARG NB_USER=jovyan

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root


# System and additional dependencies installation
RUN apt-get update && apt-get install -y \
    cmake git zlib1g-dev libtiff-dev libpng-dev libjpeg-dev \
    libssl-dev libwrap0-dev \
    vtk-dicom-tools libgdcm-tools libvtkgdcm-tools \
    dcmtk libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev \
    libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev libopenexr-dev \
    g++ make cmake-curses-gui libblas-dev liblapack-dev libsqlite3-dev \
    libdcmtk-dev libdlib-dev libfftw3-dev libinsighttoolkit4-dev \
    uuid-dev build-essential imagemagick && \
    rm -rf /var/lib/apt/lists/*


# Clone and build DCMTK
RUN mkdir -p /usr/src/dcmtk-build && \
    cd /usr/src && \
    git clone https://github.com/DCMTK/dcmtk.git && \
    cd dcmtk-build && \
    cmake ../dcmtk && \
    make -j$(nproc)

# Install DCMTK binaries to the default system paths
RUN cd /usr/src/dcmtk-build && \
    make install

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/src/*

# Verify DCMTK installation
RUN which dcm2xml && dcm2xml --version



### Plastimatch installation
RUN cd /tmp && \
    git clone https://gitlab.com/plastimatch/plastimatch.git && \
    cd plastimatch && \
    git checkout 1.9.4 && \
    mkdir build && cd build && \
    cmake -DINSTALL_PREFIX=/usr .. && \
    make -j$(nproc) && \
    make install

RUN cp /tmp/plastimatch/build/plastimatch /usr/bin


# Installation of PyTorch using pip
# Reference: https://pytorch.org/get-started/locally/
# Ignore pip install warning
RUN pip install --no-cache-dir --index-url 'https://download.pytorch.org/whl/cpu' \
    torch torchvision torchaudio && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Copy the Python requirements file
COPY requirements.txt .

# Install Python libraries from the requirements file
RUN pip install --no-cache-dir -r requirements.txt

### INSTALLING RUST:
# Install Rust using the official installer script
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Update PATH to include Rust binaries
ENV PATH="/home/jovyan/.cargo/bin:${PATH}"

# Verify Rust installation
RUN rustc --version && cargo --version

# Install Rust kernel for Jupyter
RUN cargo install evcxr_jupyter && evcxr_jupyter --install

# Update bash configuration
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

### END RUST


# Install OpenCV and SimpleITK
RUN pip install opencv-python-headless SimpleITK

CMD ["jupyter", "notebook", "--no-browser","--NotebookApp.token=''","--NotebookApp.password=''","--NotebookApp.iopub_data_rate_limit=1e10"]
