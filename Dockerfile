# 使用官方的 Python 3.11.9 Alpine 镜像作为基础镜像
FROM python:3.11.9-alpine As compile-image

# 设置工作目录
WORKDIR /app

# 复制 requirements.txt 文件到工作目录
COPY requirements.txt /app/

# 安装依赖项并清理构建依赖
RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install --trusted-host pypi.python.org -r requirements.txt \
    && apk del .build-deps && rm -rf requirements.txt

# 安装 rclone
RUN apk add --no-cache rclone

# 使用官方的 Python 3.11.9 Alpine 镜像作为运行时镜像
FROM python:3.11.9-alpine As runtime-image

# 设置工作目录
WORKDIR /app

# 复制编译镜像中的 rclone 和 Python 库
COPY --from=compile-image /usr/bin/rclone /app/rclone/rclone
COPY --from=compile-image /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# 复制项目中的必要文件和目录
COPY config.yaml data.yaml setup.py media_downloader.py /app/
COPY module /app/module
COPY utils /app/utils

# 设置默认的启动命令
CMD ["python", "media_downloader.py"]
