# 使用 Ubuntu 24.04 基础镜像
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
    jq \
 && rm -rf /var/lib/apt/lists/*

# 创建目录结构
RUN mkdir -p /sealdice /release-backup /sealdice/data /sealdice/backup

# 声明卷
VOLUME ["/sealdice/data", "/sealdice/backup"]

# 根据构建平台自动选择下载URL
ARG CONFIG_FILE
ARG BUILD_TYPE
COPY $CONFIG_FILE /config.json
RUN if [ "$BUILD_TYPE" = "stable" ]; then TAG=$(jq -r '.tag_name' /config.json); else TAG=$(jq -r '.commit_hash' /config.json | head -c 7); fi && \
    ARCH=$TARGETARCH && \
    [ "$ARCH" = "arm64" ] && ARCH=arm64 || ARCH=amd64 && \
    DOWNLOAD_URL=$(jq -r ".downloads.linux_${ARCH}" /config.json) && \
    wget -q "$DOWNLOAD_URL" -O /tmp/sealdice.tar.gz && \
    tar -xzf /tmp/sealdice.tar.gz -C /release-backup --strip-components=1 && \
    rm /tmp/sealdice.tar.gz /config.json && \
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
