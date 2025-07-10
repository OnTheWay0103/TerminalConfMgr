#!/usr/bin/env bash

# Dotf 命令合并测试脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Dotf 命令合并测试 ===${NC}"
echo ""

# 测试 1: 检查 dotf 命令是否存在
echo -e "${BLUE}1. 检查 dotf 命令${NC}"
if command -v dotf >/dev/null 2>&1; then
    echo -e "${GREEN}✅ dotf 命令已安装${NC}"
    echo "位置: $(which dotf)"
else
    echo -e "${YELLOW}⚠️  dotf 命令未安装${NC}"
    echo "请先运行: ./tools/install.sh"
fi
echo ""

# 测试 2: 检查 dotconf 命令是否还存在
echo -e "${BLUE}2. 检查 dotconf 命令${NC}"
if command -v dotconf >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  dotconf 命令仍然存在${NC}"
    echo "位置: $(which dotconf)"
    echo "建议: 可以手动删除 dotconf 符号链接"
else
    echo -e "${GREEN}✅ dotconf 命令已成功合并到 dotf${NC}"
fi
echo ""

# 测试 3: 检查脚本文件
echo -e "${BLUE}3. 检查脚本文件${NC}"
if [ -f "tools/dotconf.sh" ]; then
    echo -e "${GREEN}✅ 主脚本文件存在: tools/dotconf.sh${NC}"
else
    echo -e "${RED}❌ 主脚本文件不存在${NC}"
fi

if [ -f "tools/install.sh" ]; then
    echo -e "${GREEN}✅ 安装脚本存在: tools/install.sh${NC}"
else
    echo -e "${RED}❌ 安装脚本不存在${NC}"
fi
echo ""

# 测试 4: 检查版本信息
echo -e "${BLUE}4. 检查版本信息${NC}"
if command -v dotf >/dev/null 2>&1; then
    echo "版本信息:"
    dotf --help | head -5
else
    echo -e "${YELLOW}⚠️  无法检查版本信息（命令未安装）${NC}"
fi
echo ""

# 测试 5: 检查文档更新
echo -e "${BLUE}5. 检查文档更新${NC}"
docs_updated=true

# 检查 README.md 中的命令引用（排除文件名）
if grep -q "dotconf " README.md; then
    echo -e "${YELLOW}⚠️  README.md 中仍有 dotconf 命令引用${NC}"
    docs_updated=false
else
    echo -e "${GREEN}✅ README.md 已更新${NC}"
fi

# 检查文档目录中的命令引用（排除文件名）
if grep -r "dotconf " docs/ >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  docs/ 目录中仍有 dotconf 命令引用${NC}"
    docs_updated=false
else
    echo -e "${GREEN}✅ docs/ 目录已更新${NC}"
fi

# 检查脚本文件中的命令引用（排除文件名、变量名和测试脚本）
if grep -r "dotconf " tools/ | grep -v "DOTCONF_SCRIPT" | grep -v "install_dotconf" | grep -v "dotconf\.sh" | grep -v "test_dotf\.sh" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  tools/ 目录中仍有 dotconf 命令引用${NC}"
    docs_updated=false
else
    echo -e "${GREEN}✅ tools/ 目录已更新${NC}"
fi

echo ""

# 总结
echo -e "${BLUE}=== 测试总结 ===${NC}"
if command -v dotf >/dev/null 2>&1 && [ "$docs_updated" = true ]; then
    echo -e "${GREEN}✅ 命令合并成功！${NC}"
    echo ""
    echo -e "${BLUE}使用方法：${NC}"
    echo "  dotf init      # 初始化仓库"
    echo "  dotf sync      # 同步更改"
    echo "  dotf status    # 查看状态"
    echo "  dotf help      # 显示帮助"
    echo ""
    echo -e "${BLUE}优势：${NC}"
    echo "  • 统一的命令名称 (dotf)"
    echo "  • 更简洁的用户体验"
    echo "  • 避免了命令冲突"
    echo "  • 保持了所有原有功能"
else
    echo -e "${YELLOW}⚠️  合并过程中存在问题，请检查上述输出${NC}"
fi
echo ""
echo -e "${BLUE}测试完成！${NC}" 