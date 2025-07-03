#!/bin/bash

echo "🔍 ZSH 配置文件诊断工具"
echo "=========================="

# 检查配置文件存在性
echo "📁 配置文件检查:"
for config in ~/.zshrc ~/.zprofile ~/.zshenv ~/.zlogin ~/.zlogout ~/.zshrc_custom; do
    if [ -f "$config" ]; then
        echo "  ✅ $(basename $config) - 存在"
    else
        echo "  ❌ $(basename $config) - 不存在"
    fi
done

echo ""
echo "🔧 语法检查:"
for config in ~/.zshrc ~/.zprofile ~/.zshenv ~/.zlogin ~/.zlogout ~/.zshrc_custom; do
    if [ -f "$config" ]; then
        if zsh -n "$config" 2>/dev/null; then
            echo "  ✅ $(basename $config) - 语法正确"
        else
            echo "  ❌ $(basename $config) - 语法错误"
        fi
    fi
done

echo ""
echo "🌐 环境变量检查:"
echo "  SHELL: $SHELL"
echo "  ZSH_VERSION: $ZSH_VERSION"
echo "  JAVA_HOME: $JAVA_HOME"
echo "  PATH 前5项:"
echo "$PATH" | tr ':' '\n' | head -5 | sed 's/^/    /'

echo ""
echo "🔧 工具检查:"
echo "  Python: $(python3 --version 2>/dev/null || echo '未找到')"
echo "  Homebrew: $(brew --version 2>/dev/null | head -1 || echo '未找到')"
echo "  Java: $(java -version 2>&1 | head -1 || echo '未找到')"

echo ""
echo "📋 别名检查:"
echo "  dotf: $(alias dotf 2>/dev/null || echo '未定义')"
echo "  py: $(alias py 2>/dev/null || echo '未定义')"
echo "  cls: $(alias cls 2>/dev/null || echo '未定义')"

echo ""
echo "🎨 Oh My Zsh 检查:"
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  ✅ Oh My Zsh 已安装"
    if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
        echo "  ✅ oh-my-zsh.sh 存在"
    else
        echo "  ❌ oh-my-zsh.sh 不存在"
    fi
else
    echo "  ❌ Oh My Zsh 未安装"
fi

echo ""
echo "🔍 配置文件加载顺序:"
echo "  1. /etc/zshenv (全局环境变量)"
echo "  2. ~/.zshenv (用户环境变量)"
echo "  3. /etc/zprofile (全局登录配置)"
echo "  4. ~/.zprofile (用户登录配置)"
echo "  5. /etc/zshrc (全局交互配置)"
echo "  6. ~/.zshrc (用户交互配置)"
echo "  7. /etc/zlogin (全局登录后配置)"
echo "  8. ~/.zlogin (用户登录后配置)"

echo ""
echo "💡 调试建议:"
echo "  1. 使用 'zsh -x' 启动调试模式"
echo "  2. 检查 ~/.zshrc_custom 文件内容"
echo "  3. 确保 Oh My Zsh 正确加载"
echo "  4. 检查 PATH 变量是否正确设置" 