# Base image
FROM debian:11.0

# Install system dependencies
RUN apt-get update --fix-missing && apt-get install -y \
    wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion \
    curl grep sed dpkg tini

# Install Anaconda
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-2022.05-Linux-x86_64.sh && \
    /bin/bash /Anaconda3-2022.05-Linux-x86_64.sh -b -p /opt/conda && \
    rm /Anaconda3-2022.05-Linux-x86_64.sh

ENV PATH /opt/conda/bin:$PATH

# Install other requirements
RUN apt-get update && apt-get install -y --fix-missing \
    r-base mono-runtime libgomp1 libc6

# Fix for 'xgboost' missing
RUN conda install libgcc

# Copy the conda environment file into the image
COPY conda_env.yml /tmp/conda_env.yml

# Create the conda environment
RUN conda env create -f /tmp/conda_env.yml && \
    conda clean -a

# Activate the environment by adjusting PATH
ENV CONDA_DEFAULT_ENV=myenv
ENV PATH /opt/conda/envs/myenv/bin:$PATH

# Set working directory
WORKDIR /workspace

# Default command (can be overridden)
CMD ["/bin/bash"]
