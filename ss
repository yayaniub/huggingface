# 基础镜像
FROM debian:latest

# 更新和安装必要的软件
RUN apt-get update && \
    apt-get install -y wget unzip curl && \
    apt-get clean

# 下载并安装 Xray (VLESS 和 VMess 服务器)
RUN wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm /tmp/xray.zip

# 下载并安装 Cloudflared
RUN wget -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x /usr/local/bin/cloudflared

# 创建配置目录
RUN mkdir -p /etc/xray

# 将 Xray 配置文件复制到容器中
COPY config.json /etc/xray/config.json

# 暴露 Hugging Face 要求的端口 7860
EXPOSE 7860


# 使用 Cloudflared token 启动 Xray 和 Cloudflared
CMD xray run -c /etc/xray/config.json & cloudflared tunnel --no-autoupdate run --token ${CLOUDFLARED_TOKEN}
