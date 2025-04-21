#!/bin/bash

# 定义文件名
filename="640"

# 查找符合命名模式的文件（任意扩展名）
file=$(ls ${filename}.* 2>/dev/null | head -n 1)

# 检查文件是否存在
if [[ ! -f "$file" ]]; then
  echo "Error: ${filename}.* 文件不存在！"
  exit 1
fi

# 获取文件扩展名
extension="${file##*.}"

# 计算文件的 MD5 值
md5=$(md5sum "$file" | awk '{print $1}')

# 如果获取的 MD5 值为空，则退出
if [[ -z "$md5" ]]; then
  echo "Error: 无法计算 MD5 值！"
  exit 1
fi

# 重命名文件为 MD5 值并保留原扩展名
new_filename="${md5}-md5.${extension}"
mv "$file" "$new_filename"

# 检查重命名是否成功
if [[ $? -ne 0 ]]; then
  echo "Error: 重命名失败！"
  exit 1
fi

# 将新的文件名放入系统剪贴板
if command -v xclip &> /dev/null; then
  echo "![]($new_filename)" | xclip -selection clipboard
  echo "文件重命名为 $new_filename，已复制到剪贴板！"
elif command -v xsel &> /dev/null; then
  echo "![]($new_filename)" | xsel --clipboard
  echo "文件重命名为 $new_filename，已复制到剪贴板！"
else
  echo "Warning: 系统未安装 xclip 或 xsel，无法复制到剪贴板。"
  echo "请手动复制文件名：$new_filename"
fi

