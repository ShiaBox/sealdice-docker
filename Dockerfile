# 使用 Alpine Linux 基础镜像
FROM alpine:3.19

# 设置时区
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

# 安装运行依赖
RUN apk add --no-cache \
    gcompat \
    libstdc++ \
    libgcc \
    icu-data-full \
    icu-libs

# 创建目录结构
RUN mkdir -p /sealdice /release-backup /sealdice/data /sealdice/backup

# 声明卷
VOLUME ["/sealdice/data", "/sealdice/backup"]

# 添加配置文件
ARG CONFIG_FILE
COPY $CONFIG_FILE /config.json

# 根据构建类型和架构选择下载链接
ARG BUILD_TYPE
ARG TARGETARCH

RUN set -eux; \
    # 确定架构
    case "$TARGETARCH" in \
        amd64) ARCH="amd64" ;; \
        arm64) ARCH="arm64" ;; \
        *) ARCH="amd64" ;; \
    esac; \
    \
    # 安装临时工具
    apk add --no-cache --virtual .temp-tools curl jq; \
    \
    # 获取下载URL
    DOWNLOAD_URL=$(jq -r ".downloads.linux_$ARCH" /config.json); \
    \
    # 如果找不到小写格式，尝试首字母大写
    if [ "$DOWNLOAD_URL" = "null" ]; then \
        DOWNLOAD_URL=$(jq -r ".downloads.Linux_$ARCH" /config.json); \
    fi; \
    \
    echo "下载URL: $DOWNLOAD_URL"; \
    \
    # 下载并解压
    curl -sS -L "$DOWNLOAD_URL" -o /tmp/sealdice.tar.gz; \
    tar -xzf /tmp/sealdice.tar.gz -C /release-backup ; \
    rm /tmp/sealdice.tar.gz; \
    chmod -R 755 /release-backup/*; \
    \
    # 删除临时工具
    apk del .temp-tools

# 生成入口脚本
RUN echo "#!/bin/sh" > /entrypoint.sh && \
    echo "cp -r /release-backup/* /sealdice/" >> /entrypoint.sh && \
    echo "cd /sealdice" >> /entrypoint.sh && \
    echo "exec ./sealdice-core" >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 暴露端口并启动
EXPOSE 3211
ENTRYPOINT [ "/entrypoint.sh" ]