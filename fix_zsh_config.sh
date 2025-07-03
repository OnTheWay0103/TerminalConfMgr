#!/bin/bash

echo "🔧 ZSH 配置快速修复工具"
echo "========================"

# 检查并修复配置文件
echo "📝 检查配置文件..."

# 1. 检查 .zshrc 是否存在并包含必要内容
if [ ! -f ~/.zshrc ]; then
    echo "❌ ~/.zshrc 不存在，创建基础配置..."
    cat > ~/.zshrc << 'EOF'
# 基础 PATH 设置
export PATH="$HOME/bin:$PATH"

# 加载 Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# 加载额外配置
[ -f ~/.zshrc_custom ] && source ~/.zshrc_custom

echo "ZSH CONFIG LOADED"
EOF
    echo "✅ ~/.zshrc 已创建"
else
    echo "✅ ~/.zshrc 已存在"
fi

# 2. 检查 .zprofile 是否存在
if [ ! -f ~/.zprofile ]; then
    echo "❌ ~/.zprofile 不存在，创建基础配置..."
    cat > ~/.zprofile << 'EOF'
# 环境变量设置
export EDITOR="vim"

# Homebrew 配置
eval "$(/opt/homebrew/bin/brew shellenv)"

# Python 别名
alias py='python3'
alias python='python3'
alias pip='pip3'
alias cls='clear'
EOF
    echo "✅ ~/.zprofile 已创建"
else
    echo "✅ ~/.zprofile 已存在"
fi

# 3. 检查 .zshrc_custom 是否存在
if [ ! -f ~/.zshrc_custom ]; then
    echo "❌ ~/.zshrc_custom 不存在，创建基础配置..."
    cat > ~/.zshrc_custom << 'EOF'
# 自定义配置
# 别名
alias gac="git add . && git commit -m"
alias tf="terraform"

# 代理设置
alias proxy_on='export http_proxy=http://127.0.0.1:8080 https_proxy=$http_proxy'
alias proxy_off='unset http_proxy https_proxy'
EOF
    echo "✅ ~/.zshrc_custom 已创建"
else
    echo "✅ ~/.zshrc_custom 已存在"
fi

# 4. 语法检查
echo ""
echo "🔍 语法检查..."
for config in ~/.zshrc ~/.zprofile ~/.zshrc_custom; do
    if [ -f "$config" ]; then
        if zsh -n "$config" 2>/dev/null; then
            echo "  ✅ $(basename $config) - 语法正确"
        else
            echo "  ❌ $(basename $config) - 语法错误"
        fi
    fi
done

# 5. 重新加载配置
echo ""
echo "🔄 重新加载配置..."
source ~/.zshrc

# 6. 验证修复结果
echo ""
echo "✅ 验证修复结果..."
echo "  别名检查:"
echo "    dotf: $(alias dotf 2>/dev/null || echo '未定义')"
echo "    py: $(alias py 2>/dev/null || echo '未定义')"
echo "    cls: $(alias cls 2>/dev/null || echo '未定义')"

echo ""
echo "🎉 修复完成！"
echo "💡 如果问题仍然存在，请尝试："
echo "   1. 重启终端"
echo "   2. 运行 'source ~/.zshrc'"
echo "   3. 检查 ~/.zshrc_custom 文件内容" 