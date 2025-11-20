# Bilibili 投喂站 (Bilibili Feeder)

一个基于 Go (Gin) 和 yt-dlp 构建的极简 Bilibili 音视频解析下载工具。界面采用现代简约风格，支持视频 (MP4) 和音频 (MP3) 的独立解析与下载。

## ✨ 功能特点

- **简洁美观**：毛玻璃与卡片式 UI 设计。
- **音画分离**：支持独立提取音频或下载完整视频。
- **高性能后端**：基于 Go Gin 框架，并发处理文件流。
- **自动合并**：利用 FFmpeg 自动合并 B 站分离的音视频流。

## 🛠️ 环境依赖

本项目依赖以下工具，请确保服务器已安装：

1.  **Golang** (>= 1.18)
2.  **FFmpeg** (用于音视频合并)
3.  **yt-dlp** (核心解析工具，依赖 Python3)

---

## 📦 手动安装指南

### 1. Ubuntu / Debian 系统

```bash
# 更新源
sudo apt update

# 安装 FFmpeg 和 Python3
sudo apt install ffmpeg python3 -y

# 安装最新版 yt-dlp (推荐方式)
sudo curl -L [https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp](https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp) -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
```
### 2. CentOS / RHEL 系统
CentOS 默认源不包含 FFmpeg，需先安装 EPEL 和 RPM Fusion 源。
```bash
# 安装 EPEL 源
sudo yum install epel-release -y

# 安装 RPM Fusion (根据你的 CentOS 版本，以下以 CentOS 7/8 为例)
sudo yum install -y [https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm](https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm) -E %rhel).noarch.rpm

# 安装 FFmpeg 和 Python3
sudo yum install ffmpeg python3 -y

# 安装 yt-dlp
sudo curl -L [https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp](https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp) -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
```
