#!/usr/bin/env bash

# DotconfEx 远程同步演示脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== DotconfEx 远程同步演示 ===${NC}"
echo ""

# 检查是否已安装 dotconf
if ! command -v dotconf >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  dotconf 未安装，请先运行 install.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ dotconf 已安装${NC}"
echo ""

# 显示当前状态
echo -e "${BLUE}1. 检查当前状态${NC}"
dotconf status
echo ""

# 演示步骤
echo -e "${BLUE}=== 远程同步步骤演示 ===${NC}"
echo ""
echo "步骤 1: 初始化仓库"
echo "  dotconf init"
echo ""
echo "步骤 2: 配置远程仓库"
echo "  dotconf remote https://github.com/yourusername/dotfiles.git"
echo ""
echo "步骤 3: 添加配置文件"
echo "  dotconf add .zshrc"
echo "  dotconf add .gitconfig"
echo ""
echo "步骤 4: 同步到远程"
echo "  dotconf sync"
echo ""
echo "步骤 5: 在新设备上使用"
echo "  dotconf migrate https://github.com/yourusername/dotfiles.git"
echo ""

# 显示帮助信息
echo -e "${BLUE}=== 常用命令 ===${NC}"
echo "dotconf help          # 显示帮助"
echo "dotconf status        # 查看状态"
echo "dotconf sync          # 同步更改"
echo "dotconf add <file>    # 添加文件"
echo "dotconf remove <file> # 移除文件"
echo ""

# 显示最佳实践
echo -e "${BLUE}=== 最佳实践 ===${NC}"
echo "• 使用私有仓库存储敏感配置"
echo "• 定期同步保持配置最新"
echo "• 使用有意义的提交信息"
echo "• 为新设备准备迁移脚本"
echo ""

echo -e "${GREEN}演示完成！${NC}"
echo -e "详细说明请查看 ${BLUE}REMOTE_SYNC.md${NC}" 