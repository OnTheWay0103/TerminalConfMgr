#!/usr/bin/env bash
# 测试脚本 - 验证dotconfEx.sh的改进功能

set -euo pipefail

echo "🧪 测试 Terminal Configuration Manager v2.1"
echo "=========================================="

# 检查脚本是否存在
if [ ! -f "dotconfEx.sh" ]; then
    echo "❌ dotconfEx.sh 不存在"
    exit 1
fi

# 测试帮助信息
echo "📋 测试帮助信息..."
./dotconfEx.sh help | grep -q "add.*添加文件到跟踪" && echo "✅ 帮助信息正确" || echo "❌ 帮助信息错误"

# 测试版本信息
echo "📋 测试版本信息..."
./dotconfEx.sh help | grep -q "v2.1" && echo "✅ 版本信息正确" || echo "❌ 版本信息错误"

# 测试.gitignore创建功能（模拟）
echo "📋 测试.gitignore创建功能..."
if grep -q "create_gitignore" dotconfEx.sh; then
    echo "✅ .gitignore创建函数存在"
else
    echo "❌ .gitignore创建函数不存在"
fi

# 测试add命令
echo "📋 测试add命令..."
if grep -q "add_file()" dotconfEx.sh; then
    echo "✅ add命令函数存在"
else
    echo "❌ add命令函数不存在"
fi

# 测试remove命令
echo "📋 测试remove命令..."
if grep -q "remove_file()" dotconfEx.sh; then
    echo "✅ remove命令函数存在"
else
    echo "❌ remove命令函数不存在"
fi

echo ""
echo "🎉 测试完成！"
echo ""
echo "💡 使用方法："
echo "1. ./dotconfEx.sh init    # 初始化（会创建.gitignore）"
echo "2. ./dotconfEx.sh add .config/file  # 添加配置文件"
echo "3. ./dotconfEx.sh status  # 查看状态"
echo "4. ./dotconfEx.sh sync    # 同步更改"