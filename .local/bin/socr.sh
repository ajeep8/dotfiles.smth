#!/bin/bash

# 1. 创建一个临时目录
TMP_DIR=$(mktemp -d -t screenshot-ocr-XXXXXX)

# 2. 使用xfce4-screenshooter选择截屏模式并保存到临时目录
SCREENSHOT_PATH="$TMP_DIR/screenshot.png"
echo $SCREENSHOT_PATH
xfce4-screenshooter -r -s "$SCREENSHOT_PATH"

# 检查是否成功截屏
if [ ! -f "$SCREENSHOT_PATH" ]; then
    echo "截屏失败，退出脚本。"
    exit 1
fi

# 3. 使用docker运行OCR识别
docker run -it --rm --cpus=8 -v "$TMP_DIR":/data -e uid=$(id -u) ajeep/tr-ocr:v2.3.1

# 检查是否成功生成txt文件
OCR_TXT=$(find "$TMP_DIR" -name "*.txt")
if [ ! -f "$OCR_TXT" ]; then
    echo "OCR识别失败，退出脚本。"
    exit 2
fi

# 4. 将txt文件内容复制到剪贴板
if command -v xclip &> /dev/null; then
    cat "$OCR_TXT" | xclip -selection clipboard
elif command -v xsel &> /dev/null; then
    cat "$OCR_TXT" | xsel --clipboard --input
else
    echo "没有检测到xclip或xsel，无法复制到剪贴板。"
    exit 3
fi

echo "OCR完成，文本已复制到剪贴板。"

