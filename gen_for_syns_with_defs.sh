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

# 获取 defs.v 的绝对路径
DEFS_PATH=$(find "$DEST_DIR" -type f -name "defs.v" | head -n 1)
DEFS_ABS_PATH=$(readlink -f "$DEFS_PATH")

if [ -z "$DEFS_ABS_PATH" ]; then
    echo "defs.v not found in $DEST_DIR."
    exit 1
fi

echo "defs.v absolute path: $DEFS_ABS_PATH"

# 递归地删除目标目录内所有 .v 文件中以 include 开头的行
echo "Removing lines starting with '\`include' in .v files within $DEST_DIR..."
find "$DEST_DIR" -type f -name "*.v" -print0 | while IFS= read -r -d '' file; do
    # 创建临时文件
    temp_file=$(mktemp)
    # 删除以 include 开头的行并将结果写入临时文件
    sed '/^`include/d' "$file" > "$temp_file"
    # 将临时文件内容写回原文件
    mv "$temp_file" "$file"
done

if [ $? -ne 0 ]; then
    echo "Failed to remove lines."
    exit 1
fi

# 在每个 .v 文件开头添加 `include "PATH_TO_DEFS.V"，但排除 defs.v 文件
echo "Adding \`include \"$DEFS_ABS_PATH\" to the beginning of each .v file except defs.v..."
find "$DEST_DIR" -type f -name "*.v" ! -name "defs.v" -print0 | while IFS= read -r -d '' file; do
    temp_file=$(mktemp)
    echo "\`include \"$DEFS_ABS_PATH\"" > "$temp_file"
    cat "$file" >> "$temp_file"
    mv "$temp_file" "$file"
done

if [ $? -ne 0 ]; then
    echo "Failed to add include lines."
    exit 1
fi

echo "Operation completed successfully."