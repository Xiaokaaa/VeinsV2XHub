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
fi

# 获取当前日期
current_date=$(date "+%Y-%m-%d")

# 将commit信息和日期写入CHANGELOG.md
echo "## [$current_date]" >> "CHANGELOG.md"
echo "- $1" >> "CHANGELOG.md"
echo "" >> "CHANGELOG.md"

# 添加更改到暂存区
git add .

# 创建新的commit
git commit -m "Update CHANGELOG for changes: $1"

# 推送到远程仓库
git push