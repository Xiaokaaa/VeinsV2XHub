#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 '<commit-message>'"
    exit 1
fi

if [ ! -f "ChangeLog.md" ]; then
    echo "# Changelog" > "ChangeLog.md"
    echo "All notable changes to this project will be documented in this file." >> "ChangeLog.md"
    echo "" >> "ChangeLog.md"
fi

# 获取当前日期
current_date=$(date "+%Y-%m-%d")

last_date=$(grep '## \[' ChangeLog.md | tail -1 | cut -d '[' -f2 | cut -d ']' -f1)

if [ "$last_date" == "$current_date" ]; then
    echo "- $1" >> "ChangeLog.md"
else
    echo "## [$current_date]" >> "ChangeLog.md"
    echo "- $1" >> "ChangeLog.md"
fi

echo "" >> "ChangeLog.md"

git add .
git commit -m "$1"
git push

