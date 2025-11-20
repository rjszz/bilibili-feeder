document.addEventListener('DOMContentLoaded', function() {
    // 绑定按钮事件
    document.getElementById('btnVideo').addEventListener('click', () => download('video'));
    document.getElementById('btnAudio').addEventListener('click', () => download('audio'));
});

async function download(type) {
    const urlInput = document.getElementById('urlInput');
    const statusDiv = document.getElementById('status');
    const btnVideo = document.getElementById('btnVideo');
    const btnAudio = document.getElementById('btnAudio');
    const url = urlInput.value.trim();

    if (!url) {
        statusDiv.textContent = "⚠️ 请先输入链接";
        statusDiv.style.color = "#ff4757";
        return;
    }

    // 锁定界面
    btnVideo.disabled = true;
    btnAudio.disabled = true;
    statusDiv.textContent = "⏳ 正在解析并下载，请稍候...";
    statusDiv.style.color = "#888";
    statusDiv.classList.add('loading');

    try {
        const endpoint = type === 'video' ? '/api/parse-video' : '/api/parse-audio';
        
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ url: url })
        });

        if (!response.ok) {
            const errData = await response.json();
            throw new Error(errData.error || '下载失败');
        }

        // 处理文件流下载
        const blob = await response.blob();
        const downloadUrl = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = downloadUrl;
        
        // 从 Header 获取文件名
        const contentDisposition = response.headers.get('Content-Disposition');
        let fileName = type === 'video' ? 'bilibili_video.mp4' : 'bilibili_audio.mp3';
        
        if (contentDisposition) {
            // 简单的正则提取文件名
            const filenameMatch = contentDisposition.match(/filename="?([^";]+)"?/);
            if (filenameMatch && filenameMatch[1]) {
                fileName = decodeURIComponent(filenameMatch[1]);
            }
        }

        a.download = fileName;
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(downloadUrl);

        statusDiv.textContent = "✅ 下载完成！";
        statusDiv.style.color = "#2ecc71";

    } catch (error) {
        console.error(error);
        statusDiv.textContent = "❌ 错误: " + error.message;
        statusDiv.style.color = "#ff4757";
    } finally {
        btnVideo.disabled = false;
        btnAudio.disabled = false;
        statusDiv.classList.remove('loading');
    }
}