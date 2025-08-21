# ----------------------------------------------------------------------
# sed 's/#.*//; /^\s*$/d' ~/.zshrc
# brew install fig 配置文件检查工具
# fig doctor --verbose 配置文件扫描
# fig doctor --fix 配置文件修复
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

# ----------------------------------------------------------------------
# 使用 dotf 命令管理配置文件（已通过 install.sh 安装）
# 如果需要直接使用 git 操作，可以使用以下别名：
# alias dotf_git='/usr/bin/git --git-dir=/Users/zhaoq0103/.dotfiles --work-tree=$HOME'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Claude Code environment variables (请设置实际的环境变量)
export ANTHROPIC_BASE_URL=${ANTHROPIC_BASE_URL:-https://api.anthropic.com}
export ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-your_api_key_here}

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
