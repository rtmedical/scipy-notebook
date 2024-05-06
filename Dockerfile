# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook
FROM $BASE_CONTAINER
ARG CONDA_DIR=/opt/conda
ARG NB_USER=jovyan
LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"
# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install PyTorch with pip (https://pytorch.org/get-started/locally/)
# hadolint ignore=DL3013
RUN pip install --no-cache-dir --index-url 'https://download.pytorch.org/whl/cpu' \
    'torch' \
    'torchvision' \
    'torchaudio'  && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

 

# Copia o arquivo de requisitos para o diretório de trabalho atual
COPY requirements.txt .

# Instala as bibliotecas Python especificadas no arquivo de requisitos
RUN pip install --no-cache-dir -r requirements.txt

# Instalar dependências de sistema
RUN apt-get update && apt-get install -y \
    cmake \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*



### INSTALANDO RUST:
# Instalar o Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Configurar o ambiente
# Adiciona o diretório cargo bin ao PATH do usuário jovyan
ENV PATH="/home/jovyan/.cargo/bin:${PATH}"

# Verifique se o Rust foi instalado corretamente
RUN rustc --version && cargo --version

# Instale o kernel de Rust para Jupyter
RUN cargo install evcxr_jupyter && evcxr_jupyter --install

RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc


    ### RUST


### plastimatch
RUN cd /tmp && \
git clone https://gitlab.com/plastimatch/plastimatch.git && \
cd plastimatch  && \
mkdir build && cd build && \
cmake -DINSTALL_PREFIX=/usr .. && \
make && make install && \
cp plastimatch /usr/bin

RUN apt-get update && apt-get install -y \
    cmake \
    git \
    zlib1g-dev \
    libtiff-dev \
    libpng-dev \
    libjpeg-dev \
    libssl-dev \
    libwrap0-dev \
    && rm -rf /var/lib/apt/lists/*
 
RUN git clone https://github.com/DCMTK/dcmtk.git && \

# start build
    mkdir dcmtk-3.6.4-build && \
    cd dcmtk-3.6.4-build && \
    cmake ../dcmtk && \
    make -j8 && \
    make DESTDIR=../dcmtk-3.6.4-install install

#copiando binarios para a pasta /usr/bin
RUN cp /usr/src/dcmtk-3.6.4-install/usr/local/bin/* /usr/bin/ 
RUN mkdir /usr/local/share/dcmtk
RUN cp -r /usr/src/dcmtk-3.6.4-install/usr/local/share/dcmtk/* /usr/local/share/dcmtk


# Instalar OpenCV e SimpleITK
RUN pip install opencv-python-headless SimpleITK




CMD ["jupyter", "notebook", "--no-browser","--NotebookApp.token=''","--NotebookApp.password=''","--NotebookApp.iopub_data_rate_limit=1e10"]
