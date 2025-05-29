# 使用 Ubuntu 最新长期支持版作为基础镜像
FROM ubuntu:22.04

# 设置非交互式模式避免交互提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置 shell 为 bash
SHELL ["/bin/bash", "-c"]

# 安装基本构建工具和依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl wget git ca-certificates \
    libffi-dev libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev libgdbm-dev libnss3-dev liblzma-dev \
    xz-utils tk-dev uuid-dev cmake pkg-config \
    g++ flex bison autoconf automake libtool \
    libfl2 libfl-dev help2man python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 安装 Python 3.12.6
RUN wget https://www.python.org/ftp/python/3.12.6/Python-3.12.6.tgz && \
    tar -xf Python-3.12.6.tgz && cd Python-3.12.6 && \
    ./configure --enable-optimizations && make -j$(nproc) && make altinstall && \
    cd .. && rm -rf Python-3.12.6 Python-3.12.6.tgz

# 使用 python3.12 和 pip3.12
RUN ln -s /usr/local/bin/python3.12 /usr/bin/python && \
    ln -s /usr/local/bin/pip3.12 /usr/bin/pip

# 安装 GCC 14.1.0（从 sourceware.org 下载）
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-14.1.0/gcc-14.1.0.tar.gz && \
    tar -xf gcc-14.1.0.tar.gz && cd gcc-14.1.0 && \
    ./contrib/download_prerequisites && \
    mkdir build && cd build && \
    ../configure --enable-languages=c,c++ --disable-multilib && \
    make -j$(nproc) && make install && \
    cd ../.. && rm -rf gcc-14.1.0 gcc-14.1.0.tar.gz

# 验证 GCC 版本
RUN gcc --version

# 安装 verilator（从 GitHub 编译最新版）
RUN git clone https://github.com/verilator/verilator.git && \
    cd verilator && \
    git checkout stable && \
    autoconf && ./configure && make -j$(nproc) && make install && \
    cd .. && rm -rf verilator

# 安装 Python 包（如 openai）
RUN pip install --upgrade pip && \
    pip install openai

# 创建工作目录
WORKDIR /workspace

# 默认 shell
CMD [ "bash" ]
