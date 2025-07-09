#!/usr/bin/env bash
# Terminal Configuration Manager v2.3 - Single Repository Design
# 兼容 bash 和 zsh 环境，优先使用 bash 确保最佳兼容性

# 配置变量
DOTFILES_REPO="${DOTFILES_DIR:-$HOME/.dotfiles}"
LOG_FILE="${HOME}/.dotconf.log"
BACKUP_DIR="${HOME}/.dotconf_backups"
VERSION="2.3"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log() {
    local level="${2:-INFO}"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local message="[$timestamp] [$level] $1"
    
    case "$level" in
        "ERROR") echo -e "${RED}${message}${NC}" | tee -a "$LOG_FILE" ;;
        "WARN")  echo -e "${YELLOW}${message}${NC}" | tee -a "$LOG_FILE" ;;
        "SUCCESS") echo -e "${GREEN}${message}${NC}" | tee -a "$LOG_FILE" ;;
        "INFO")  echo -e "${BLUE}${message}${NC}" | tee -a "$LOG_FILE" ;;
        *)       echo "$message" | tee -a "$LOG_FILE" ;;
    esac
}

error_exit() {
    log "错误: $1" "ERROR"
    exit 1
}

# 检测当前 shell 类型
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# 获取脚本目录 - 兼容 bash 和 zsh
get_script_dir() {
    local source=""
    local dir=""
    
    # 检测当前 shell
    if [ -n "${BASH_SOURCE[0]}" ]; then
        # bash 环境
        source="${BASH_SOURCE[0]}"
    elif [ -n "${(%):-%x}" ]; then
        # zsh 环境
        source="${(%):-%x}"
    else
        # 回退方案
        source="$0"
    fi
    
    while [ -L "$source" ]; do
        dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done
    
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    echo "$dir"
}

# 检查依赖
check_dependencies() {
    local deps=("git" "tar")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            error_exit "缺少依赖: $dep"
        fi
    done
}

# 创建符号链接
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$target" "$backup"
        log "📦 已备份: $backup" "INFO"
    fi
    
    if [ -L "$target" ]; then
        rm "$target"
    fi
    
    ln -sf "$source" "$target"
    log "🔗 已链接: $target -> $source" "SUCCESS"
}

# 初始化仓库
init_repo() {
    log "初始化dotfiles仓库..." "INFO"
    
    if [ -d "${DOTFILES_REPO}" ]; then
        log "⚠️ 仓库已存在: ${DOTFILES_REPO}" "WARN"
        read -p "重新初始化？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
        rm -rf "$DOTFILES_REPO"
    fi

    check_dependencies
    mkdir -p "$DOTFILES_REPO"
    cd "$DOTFILES_REPO"
    git init
    
    # 创建.gitignore
    cat > .gitignore << 'EOF'
# 系统文件
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# 临时文件
*.tmp
*.temp
*.swp
*.swo
*~
.#*
\#*#

# 日志文件
*.log
logs/
log/

# 备份文件
*.bak
*.backup
*.old
*.orig

# 缓存文件
.cache/
*.cache

# 编译文件
*.o
*.so
*.dylib
*.dll
*.exe

# 压缩文件
*.zip
*.tar.gz
*.tar.bz2
*.rar
*.7z

# IDE 和编辑器文件
.vscode/
.idea/
*.sublime-*
.atom/
.brackets.json

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/

# Ruby
*.gem
*.rbc
/.config
/coverage/
/InstalledFiles
/pkg/
/spec/reports/
/spec/examples.txt
/test/tmp/
/test/version_tmp/
/tmp/

# Java
*.class
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar
hs_err_pid*

# Go
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
go.work

# Rust
/target/
Cargo.lock

# 用户输入文件（根据用户规则）
userinput.py

# dotconfEx 相关文件
.dotconf.log
.dotconf_backups/
.dotfiles/

# 用户自定义配置（可选）
# 如果用户想要跟踪自己的配置文件，可以取消注释
# configs/.zshrc_custom
# configs/.gitconfig_local

# 其他
*.pid
*.seed
*.pid.lock 
EOF
    
    # 询问远程仓库
    echo -e "\n${BLUE}配置远程仓库？${NC}"
    read -p "远程URL (可选): " remote_url
    if [ -n "$remote_url" ]; then
        git remote add origin "$remote_url"
        log "✅ 已配置远程仓库" "SUCCESS"
    fi
    
    # 创建基础配置
    create_base_configs
    create_symlinks
    
    # 初始提交
    git add .
    git commit -m "🎉 初始提交 - $(date)"
    
    if [ -n "$remote_url" ]; then
        echo -e "\n${BLUE}推送到远程？${NC}"
        read -p "(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push -u origin main
            log "🚀 已推送" "SUCCESS"
        fi
    fi
    
    log "✅ 仓库初始化完成" "SUCCESS"
}

# 创建基础配置
create_base_configs() {
    # 获取脚本所在目录
    local script_dir="$(get_script_dir)"
    local templates_dir="${script_dir}/../templates"
    
    # 检查模板目录是否存在
    if [ ! -d "$templates_dir" ]; then
        log "⚠️ 模板目录不存在: $templates_dir" "WARN"
        log "使用内置模板创建基础配置" "INFO"
        create_builtin_configs
        return
    fi
    
    # 从模板目录复制配置文件
    local config_files=(
        "zshrc.example:.zshrc"
        "zshrc_custom.example:.zshrc_custom"
        "gitconfig.example:.gitconfig"
        "vimrc.example:.vimrc"
    )
    
    for config_pair in "${config_files[@]}"; do
        local template_file="${config_pair%%:*}"
        local target_file="${config_pair##*:}"
        
        if [ -f "${templates_dir}/${template_file}" ]; then
            cp "${templates_dir}/${template_file}" "${DOTFILES_REPO}/${target_file}"
            log "📋 已从模板创建: ${target_file}" "SUCCESS"
        else
            log "⚠️ 模板文件不存在: ${template_file}" "WARN"
        fi
    done
    
    log "✅ 已从模板创建基础配置" "SUCCESS"
}

# 创建内置配置（备用方案）
create_builtin_configs() {
    cat > .zshrc << 'EOF'
# Zsh Configuration
export LANG=en_US.UTF-8
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

autoload -Uz compinit
compinit

PS1='%F{green}%n@%m%f:%F{blue}%~%f$ '

alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

if [ -f ~/.zshrc_custom ]; then
    source ~/.zshrc_custom
fi
EOF

    cat > .zshrc_custom << 'EOF'
# 自定义配置
# 在这里添加个人配置
EOF

    cat > .gitconfig << 'EOF'
[user]
    name = Your Name
    email = your.email@example.com

[core]
    editor = vim
    autocrlf = input

[init]
    defaultBranch = main

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    ca = commit -a
    cm = commit -m
    unstage = reset HEAD --

[color]
    ui = auto
EOF

    cat > .vimrc << 'EOF'
" Vim Configuration
set nocompatible
set number
set ruler
set showmatch
set ignorecase
set smartcase
set incsearch
set hlsearch
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set backspace=indent,eol,start
set history=1000
set wildmenu
set title
set visualbell
set noerrorbells

syntax on
filetype plugin indent on
set background=dark
colorscheme default
EOF

    log "✅ 已创建内置基础配置" "SUCCESS"
}

# 创建符号链接
create_symlinks() {
    local files=(.zshrc .zshrc_custom .gitconfig .vimrc)
    
    for file in "${files[@]}"; do
        # 优先使用 configs/ 目录下的配置文件
        if [ -f "${DOTFILES_REPO}/configs/${file}" ]; then
            create_symlink "${DOTFILES_REPO}/configs/${file}" "${HOME}/${file}"
        elif [ -f "${DOTFILES_REPO}/${file}" ]; then
            # 回退到根目录下的文件
            create_symlink "${DOTFILES_REPO}/${file}" "${HOME}/${file}"
        fi
    done
}

# 配置远程仓库
setup_remote() {
    local remote_url="$1"
    
    if [ -z "$remote_url" ]; then
        error_exit "缺少远程仓库 URL"
    fi
    
    if [ ! -d "$DOTFILES_REPO" ]; then
        error_exit "仓库不存在，请先运行 'init'"
    fi
    
    cd "$DOTFILES_REPO"
    
    # 检查是否已有远程仓库
    if git remote -v | grep -q 'origin'; then
        log "⚠️ 远程仓库已存在" "WARN"
        read -p "是否重新配置？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
        git remote remove origin
    fi
    
    # 添加远程仓库
    git remote add origin "$remote_url"
    log "✅ 已添加远程仓库: $remote_url" "SUCCESS"
    
    # 推送到远程
    echo -e "\n${BLUE}推送到远程仓库？${NC}"
    read -p "(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push -u origin main
        log "🚀 已推送到远程仓库" "SUCCESS"
    fi
}

# 同步更改
sync_changes() {
    if [ ! -d "$DOTFILES_REPO" ]; then
        error_exit "仓库不存在，请先运行 'init'"
    fi
    
    cd "$DOTFILES_REPO"
    
    # 检查远程更改
    if git remote -v | grep -q 'origin'; then
        log "📥 检查远程更改..." "INFO"
        git fetch origin
        
        local local_commit=$(git rev-parse HEAD 2>/dev/null || echo "")
        local remote_commit=$(git rev-parse origin/main 2>/dev/null || echo "")
        
        if [ "$local_commit" != "$remote_commit" ] && [ -n "$remote_commit" ]; then
            log "🔄 合并远程更改..." "INFO"
            if git merge origin/main --allow-unrelated-histories --no-edit; then
                log "✅ 远程更改已合并" "SUCCESS"
            else
                log "⚠️ 合并冲突，请手动解决" "WARN"
                log "解决冲突后运行: git add . && git commit" "INFO"
                return 1
            fi
        else
            log "✅ 本地已是最新版本" "INFO"
        fi
    else
        log "⚠️ 未配置远程仓库" "WARN"
        echo -e "\n${BLUE}是否配置远程仓库？${NC}"
        read -p "远程仓库 URL: " remote_url
        if [ -n "$remote_url" ]; then
            setup_remote "$remote_url"
        fi
    fi
    
    # 检查本地更改
    local status_output=$(git status --porcelain 2>/dev/null)
    if [ ${#status_output} -eq 0 ]; then
        log "ℹ️ 没有本地更改" "INFO"
        return 0
    fi

    log "📝 检测到本地更改:" "INFO"
    echo "$status_output"

    # 提交更改
    git add .
    local commit_message="🔄 同步: $(date +'%Y-%m-%d %H:%M:%S')"
    git commit -m "$commit_message"
    log "✅ 已提交更改" "SUCCESS"
    
    # 推送到远程
    if git remote -v | grep -q 'origin'; then
        if git push origin main; then
            log "🚀 已推送到远程仓库" "SUCCESS"
        else
            log "⚠️ 推送失败，请检查网络连接和权限" "WARN"
            return 1
        fi
    else
        log "ℹ️ 未配置远程仓库，更改仅保存在本地" "INFO"
    fi
}

# 迁移配置
migrate_config() {
    local repo_url="$1"
    
    if [ -z "$repo_url" ]; then
        error_exit "缺少Git URL"
    fi
    
    check_dependencies
    
    if [ -d "$DOTFILES_REPO" ]; then
        mv "$DOTFILES_REPO" "${DOTFILES_REPO}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    git clone "$repo_url" "$DOTFILES_REPO"
    create_symlinks
    
    log "✅ 配置迁移完成" "SUCCESS"
}

# 添加文件
add_file() {
    local file_path="$1"
    
    if [ -z "$file_path" ]; then
        error_exit "缺少文件路径"
    fi
    
    if [ ! -d "$DOTFILES_REPO" ]; then
        error_exit "仓库不存在，请先运行 'init'"
    fi
    
    if [ ! -f "${HOME}/${file_path}" ]; then
        error_exit "文件不存在: ${HOME}/${file_path}"
    fi
    
    local target_file="${DOTFILES_REPO}/${file_path}"
    mkdir -p "$(dirname "$target_file")"
    cp "${HOME}/${file_path}" "$target_file"
    create_symlink "$target_file" "${HOME}/${file_path}"
    
    cd "$DOTFILES_REPO"
    git add "$file_path"
    
    log "✅ 已添加: $file_path" "SUCCESS"
}

# 移除文件
remove_file() {
    local file_path="$1"
    
    if [ -z "$file_path" ]; then
        error_exit "缺少文件路径"
    fi
    
    if [ ! -d "$DOTFILES_REPO" ]; then
        error_exit "仓库不存在，请先运行 'init'"
    fi
    
    cd "$DOTFILES_REPO"
    git rm --cached "$file_path" 2>/dev/null || error_exit "移除失败"
    
    local backup_file="${HOME}/${file_path}.backup.*"
    if ls $backup_file 1> /dev/null 2>&1; then
        local latest_backup=$(ls -t $backup_file | head -1)
        rm "${HOME}/${file_path}"
        mv "$latest_backup" "${HOME}/${file_path}"
        log "🔄 已恢复原文件" "INFO"
    fi
    
    log "✅ 已移除: $file_path" "SUCCESS"
}

# 显示状态
show_status() {
    echo -e "\n${BLUE}=== Dotconf 状态 ===${NC}"
    echo -e "版本: $VERSION"
    echo -e "仓库: $DOTFILES_REPO"
    
    if [ -d "$DOTFILES_REPO" ]; then
        echo -e "\n${GREEN}✅ 仓库存在${NC}"
        cd "$DOTFILES_REPO"
        
        if git remote -v | grep -q 'origin'; then
            echo -e "${GREEN}✅ 远程已配置${NC}"
        else
            echo -e "${YELLOW}⚠️ 无远程仓库${NC}"
        fi
        
        local status_output=$(git status --porcelain 2>/dev/null)
        if [ -n "$status_output" ]; then
            echo -e "\n${YELLOW}📝 待提交:${NC}"
            echo "$status_output"
        else
            echo -e "\n${GREEN}✅ 工作目录干净${NC}"
        fi
        
        echo -e "\n${BLUE}📁 跟踪文件:${NC}"
        git ls-files | while read -r file; do
            echo "   $file"
        done
    else
        echo -e "\n${RED}❌ 仓库不存在${NC}"
    fi
    
    echo -e "\n${BLUE}=== 结束 ===${NC}\n"
}

# 显示帮助
show_help() {
    echo -e "${BLUE}Terminal Configuration Manager v$VERSION${NC}\n"
    echo "单仓库设计 - 简化配置文件管理"
    echo ""
    echo "命令:"
    echo "  init     初始化仓库"
    echo "  sync     同步更改"
    echo "  remote   配置远程仓库"
    echo "  migrate  迁移到新机器"
    echo "  add      添加文件"
    echo "  remove   移除文件"
    echo "  status   显示状态"
    echo "  help     显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 init                    # 首次设置"
    echo "  $0 remote <URL>            # 配置远程仓库"
    echo "  $0 add .config/nvim/init.vim  # 添加配置"
    echo "  $0 sync                    # 同步更改"
    echo "  $0 migrate <URL>           # 新机器"
    echo ""
    echo "远程同步:"
    echo "  1. dotconf init            # 初始化"
    echo "  2. dotconf remote <URL>    # 配置远程"
    echo "  3. dotconf sync            # 同步更改"
    echo ""
    echo "特点:"
    echo "  - 单仓库管理"
    echo "  - 自动符号链接"
    echo "  - 远程同步支持"
    echo "  - 简单易用"
    echo ""
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    case "$1" in
        init)
            init_repo
            ;;
        sync)
            sync_changes
            ;;
        remote)
            if [ -z "${2:-}" ]; then
                error_exit "缺少远程仓库 URL"
            fi
            setup_remote "$2"
            ;;
        migrate)
            if [ -z "${2:-}" ]; then
                error_exit "缺少Git URL"
            fi
            migrate_config "$2"
            ;;
        add)
            if [ -z "${2:-}" ]; then
                error_exit "缺少文件路径"
            fi
            add_file "$2"
            ;;
        remove)
            if [ -z "${2:-}" ]; then
                error_exit "缺少文件路径"
            fi
            remove_file "$2"
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log "未知命令: $1" "ERROR"
            show_help
            exit 1
            ;;
    esac
}

main "$@"