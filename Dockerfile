FROM ubuntu:24.04

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    libicu74 \
    ca-certificates \
    wget \
    tar \
 && rm -rf /var/lib/apt/lists/*

# 创建目录结构
RUN mkdir -p /release-backup /sealdice/data /sealdice/backup

# 声明卷
VOLUME ["/sealdice/data", "/sealdice/backup"]

# 下载应用文件到备份目录
RUN wget -q https://github.com/sealdice/sealdice-build/releases/download/pre-release/sealdice_20250603-10aa805_linux_amd64.tar.gz -O /tmp/sealdice.tar.gz && \
    tar -xzf /tmp/sealdice.tar.gz -C /release-backup --strip-components=1 && \
    rm /tmp/sealdice.tar.gz && \
    chmod -R 755 /release-backup/*  

# 生成入口脚本
RUN echo "#!/bin/sh" > /entrypoint.sh && \
    echo "cp -r /release-backup/* /sealdice/" >> /entrypoint.sh && \
    echo "cd /sealdice" >> /entrypoint.sh && \
    echo "./sealdice-core" >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 暴露端口并启动
EXPOSE 3211
ENTRYPOINT [ "/entrypoint.sh" ]