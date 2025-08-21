# ----------------------------------------------------------------------
# 在 `~/.zshrc` 中仅保留基础设置：
# ~/.zshrc
export PATH="$HOME/bin:$PATH"

# 加载 Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
# 设置主题（必须在 Oh My Zsh 加载之前）
ZSH_THEME="jonathan"
source $ZSH/oh-my-zsh.sh

# 加载额外配置（重要！）
[ -f ~/.zshrc_custom ] && source ~/.zshrc_custom

echo "ZSH CONFIG LOADED"

