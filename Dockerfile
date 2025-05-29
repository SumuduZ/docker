# 使用 Debian 作为基础镜像
FROM debian:11.0

# 设置 shell 为 bash，确保 conda init 生效
SHELL ["/bin/bash", "-c"]

# 安装系统依赖
RUN apt-get update --fix-missing && apt-get install -y \
    wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion \
    curl grep sed dpkg tini \
    r-base mono-runtime libgomp1 libc6

# 安装 Anaconda
RUN wget --quiet https://repo.continuum.io/archive/Anaconda3-2022.05-Linux-x86_64.sh && \
    /bin/bash Anaconda3-2022.05-Linux-x86_64.sh -b -p /opt/conda && \
    rm Anaconda3-2022.05-Linux-x86_64.sh

# 设置 Conda 路径并初始化 shell
ENV PATH="/opt/conda/bin:$PATH"
RUN conda init bash

# 拷贝 Conda 环境文件
COPY conda_env.yml /tmp/conda_env.yml

# 创建 Conda 环境并配置自动激活
RUN conda env create -f /tmp/conda_env.yml && \
    echo "conda activate myenv" >> ~/.bashrc && \
    conda clean -a

# 默认环境和路径设置
ENV CONDA_DEFAULT_ENV=myenv
ENV PATH="/opt/conda/envs/myenv/bin:$PATH"

# 设置工作目录
WORKDIR /workspace

# 默认命令：启动 bash，Codabench 会执行其中命令
CMD ["bash"]
