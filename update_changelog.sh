#!/bin/bash

# 检查是否提供了参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 '<commit-message>'"
    exit 1
fi

# 检查CHANGELOG.md文件是否存在，如果不存在则创建
if [ ! -f "CHANGELOG.md" ]; then
    echo "# Changelog" > "CHANGELOG.md"
    echo "All notable changes to this project will be documented in this file." >> "CHANGELOG.md"
    echo "" >> "CHANGELOG.md"
fi

# 获取当前日期
current_date=$(date "+%Y-%m-%d")

# 检查最后一次记录的日期是否是今天
last_date=$(grep '## \[' CHANGELOG.md | tail -1 | cut -d '[' -f2 | cut -d ']' -f1)

if [ "$last_date" == "$current_date" ]; then
    # 如果是今天，则追加到最后一个日志条目
    echo "- $1" >> "CHANGELOG.md"
else
    # 如果不是今天，新增一个日志条目
    echo "## [$current_date]" >> "CHANGELOG.md"
    echo "- $1" >> "CHANGELOG.md"
fi

echo "" >> "CHANGELOG.md"

# 添加CHANGELOG.md到暂存区
git add .

# 创建新的commit
git commit -m "$1"

# 推送到远程仓库
git push

