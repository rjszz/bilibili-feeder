#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}    Bilibili 投喂站 - 一键环境部署脚本    ${NC}"
echo -e "${YELLOW}=========================================${NC}"

# 检查是否以 root 运行
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ 请使用 root 权限运行此脚本 (sudo ./deploy.sh)${NC}"
  exit 1
fi

# 检测系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    echo -e "${GREEN}➡️  检测到系统: $OS${NC}"
else
    echo -e "${RED}❌ 无法检测系统类型，脚本退出${NC}"
    exit 1
fi

# ===========================
# 1. 安装基础依赖 (FFmpeg & Python)
# ===========================
echo -e "\n${YELLOW}📦 [1/4] 正在安装 FFmpeg 和 Python...${NC}"

if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    apt-get update
    apt-get install -y ffmpeg python3 curl
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Alma"* ]] || [[ "$OS" == *"Rocky"* ]]; then
    # CentOS 需要安装 EPEL 和 RPM Fusion 才能装 FFmpeg
    echo "正在配置 CentOS 源..."
    yum install -y epel-release
    
    # 尝试安装 RPM Fusion
    if ! rpm -q rpmfusion-free-release > /dev/null; then
        yum install -y https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm
    fi
    
    yum install -y ffmpeg python3 curl
else
    echo -e "${RED}❌ 不支持的系统类型，请参考 README 手动安装 FFmpeg${NC}"
    exit 1
fi

# 验证 FFmpeg
if command -v ffmpeg >/dev/null 2>&1; then
    echo -e "${GREEN}✅ FFmpeg 安装成功!${NC}"
else
    echo -e "${RED}❌ FFmpeg 安装失败，请检查源配置。${NC}"
    exit 1
fi

# ===========================
# 2. 安装 yt-dlp
# ===========================
echo -e "\n${YELLOW}📥 [2/4] 正在安装最新版 yt-dlp...${NC}"

curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp

if command -v yt-dlp >/dev/null 2>&1; then
    VERSION=$(yt-dlp --version)
    echo -e "${GREEN}✅ yt-dlp 安装成功! 版本: $VERSION${NC}"
else
    echo -e "${RED}❌ yt-dlp 安装失败${NC}"
    exit 1
fi

# ===========================
# 3. 检查 Go 环境
# ===========================
echo -e "\n${YELLOW}🐹 [3/4] 检查 Go 环境...${NC}"

if command -v go >/dev/null 2>&1; then
    GO_VER=$(go version)
    echo -e "${GREEN}✅ 检测到 Go 环境: $GO_VER${NC}"
else
    echo -e "${RED}⚠️  未检测到 Go 环境${NC}"
    echo -e "请手动安装 Go (推荐版本 1.20+): https://go.dev/dl/"
    echo -e "或者使用包管理器安装: apt install golang / yum install golang"
    # 这里不自动安装 Go，因为 Go 的版本管理较复杂，交给用户决定
    exit 1
fi

# ===========================
# 4. 初始化项目
# ===========================
echo -e "\n${YELLOW}🚀 [4/4] 初始化项目依赖...${NC}"

# 删除旧的 go.mod 防止冲突 (可选)
if [ -f "go.mod" ]; then
    echo "发现旧的 go.mod，正在清理并重新初始化..."
    rm go.mod go.sum
fi

go mod init bilibili-feeder
go get github.com/gin-gonic/gin
go get github.com/google/uuid
go mod tidy

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}   🎉 部署完成！应用已准备就绪   ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "你可以使用以下命令启动服务："
echo -e "${YELLOW}go run main.go${NC}"
echo -e "服务端口: 8080"