package main

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// RequestBody 定义前端传来的JSON结构
type RequestBody struct {
	URL string `json:"url" binding:"required"`
}

func main() {
	r := gin.Default()

	// 设置HTML模板和静态文件路径
	// 注意：在生产环境中建议使用 go:embed 打包静态资源
	r.Static("/static", "./static")
	r.LoadHTMLGlob("static/*.html")

	// 确保临时目录存在
	os.MkdirAll("temp", 0755)

	// 首页路由
	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", nil)
	})

	// API 路由组
	api := r.Group("/api")
	{
		api.POST("/parse-video", func(c *gin.Context) {
			handleDownload(c, "video")
		})
		api.POST("/parse-audio", func(c *gin.Context) {
			handleDownload(c, "audio")
		})
	}

	// 启动服务 (默认 8080)
	fmt.Println("🚀 Bilibili 投喂站已启动: http://localhost:8080")
	r.Run(":8080")
}

func handleDownload(c *gin.Context, fileType string) {
	var req RequestBody
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的请求参数"})
		return
	}

	// 生成唯一的临时文件名，防止冲突
	jobID := uuid.New().String()
	tempDir := "temp"
	outputTemplate := filepath.Join(tempDir, jobID+".%(ext)s")

	var cmd *exec.Cmd
	var targetExt string

	// 构建 yt-dlp 命令
	if fileType == "video" {
		// 下载最佳画质并合并为 mp4
		cmd = exec.Command("yt-dlp",
			"-f", "bestvideo+bestaudio/best",
			"--merge-output-format", "mp4",
			"-o", outputTemplate,
			req.URL,
		)
		targetExt = ".mp4"
	} else {
		// 提取音频并转换为 mp3
		cmd = exec.Command("yt-dlp",
			"-x",
			"--audio-format", "mp3",
			"-o", outputTemplate,
			req.URL,
		)
		targetExt = ".mp3"
	}

	// 执行下载命令
	fmt.Printf("正在处理: %s (类型: %s)\n", req.URL, fileType)
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Printf("下载失败: %s\n", string(output))
		c.JSON(http.StatusInternalServerError, gin.H{"error": "解析或下载失败，请检查链接是否有效"})
		return
	}

	// 找到最终生成的文件 (yt-dlp 可能会自动修正扩展名)
	finalPath := filepath.Join(tempDir, jobID+targetExt)

	// 检查文件是否存在
	if _, err := os.Stat(finalPath); os.IsNotExist(err) {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "文件生成失败"})
		return
	}

	// 确保在发送完成后删除文件
	defer func() {
		go func() {
			time.Sleep(10 * time.Second) // 稍微延迟删除以确保传输开始
			os.Remove(finalPath)
			fmt.Println("清理临时文件:", finalPath)
		}()
	}()

	// 设置响应头，强制下载
	fileName := fmt.Sprintf("bilibili_%s_%s%s", fileType, time.Now().Format("150405"), targetExt)
	c.Writer.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s\"", fileName))
	c.File(finalPath)
}
