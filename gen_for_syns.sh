#!/bin/bash

# 检查输入参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
fi

SOURCE_DIR="$1"
DEST_DIR="$2"

# 确保目标目录存在
rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"

# 递归地复制所有 .v 文件，并忽略 .git 目录
echo "Copying .v files from $SOURCE_DIR to $DEST_DIR, ignoring .git directories..."
rsync -av --exclude='.git/' --include='*/' --include='*.v' --exclude='*' "$SOURCE_DIR/" "$DEST_DIR/"

if [ $? -ne 0 ]; then
    echo "Failed to copy files."
    exit 1
fi

# 递归地删除目标目录内所有 .v 文件中以 include 开头的行
echo "Removing lines starting with '\`include' in .v files within $DEST_DIR..."
find "$DEST_DIR" -type f -name "*.v" -print0 | while IFS= read -r -d '' file; do
    # 创建临时文件
    temp_file=$(mktemp)
    # 删除以 include 开头的行并将结果写入临时文件
    sed '/^\`include/d' "$file" > "$temp_file"
    # 将临时文件内容写回原文件
    mv "$temp_file" "$file"
done

if [ $? -ne 0 ]; then
    echo "Failed to remove lines."
    exit 1
fi

echo "Operation completed successfully."