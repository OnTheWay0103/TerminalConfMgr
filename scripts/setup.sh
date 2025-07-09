#!/usr/bin/env bash

# DotconfEx 单仓库设计设置脚本
# 演示如何在单仓库中管理工具和配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== DotconfEx 单仓库设计演示 ===${NC}"
echo ""

# 检查当前目录结构
echo -e "${BLUE}1. 检查仓库结构${NC}"
echo "当前目录: $(pwd)"
echo ""

if [ -d "tools" ] && [ -d "configs" ] && [ -d "docs" ]; then
    echo -e "${GREEN}✅ 单仓库结构正确${NC}"
    echo "├── tools/     # 工具脚本"
    echo "├── configs/   # 配置文件"
    echo "└── docs/      # 文档"
    echo ""
else
    echo -e "${RED}❌ 仓库结构不正确${NC}"
    exit 1
fi

# 显示工具脚本
echo -e "${BLUE}2. 工具脚本${NC}"
ls -la tools/
echo ""

# 显示配置文件
echo -e "${BLUE}3. 配置文件${NC}"
ls -la configs/
echo ""

# 显示文档
echo -e "${BLUE}4. 文档${NC}"
ls -la docs/
echo ""

# 演示安装流程
echo -e "${BLUE}5. 安装流程演示${NC}"
echo "步骤 1: 安装工具"
echo "  ./tools/install.sh"
echo ""
echo "步骤 2: 初始化配置"
echo "  dotconf init"
echo ""
echo "步骤 3: 自定义配置"
echo "  # 编辑 configs/ 目录下的文件"
echo ""
echo "步骤 4: 同步到远程"
echo "  dotconf sync"
echo ""

# 显示单仓库设计的优势
echo -e "${BLUE}=== 单仓库设计优势 ===${NC}"
echo "✅ 工具和配置在同一个仓库"
echo "✅ 只需要克隆一个仓库"
echo "✅ 统一的版本控制"
echo "✅ 简化的部署流程"
echo "✅ 便于维护和管理"
echo ""

echo -e "${GREEN}单仓库设计演示完成！${NC}"
echo -e "详细说明请查看 ${BLUE}docs/REPOSITORY_DESIGN.md${NC}" 