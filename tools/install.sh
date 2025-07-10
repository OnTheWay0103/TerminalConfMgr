#!/usr/bin/env bash

# Dotf 一键安装脚本 - 单仓库设计
# 兼容 bash 和 zsh 环境
# 参考 Mathias Bynens dotfiles 的 bootstrap.sh 设计

set -e

DOTFILES_REPO="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTCONF_SCRIPT="dotconf.sh"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    local deps=("git" "curl")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "缺少依赖: ${missing_deps[*]}"
        exit 1
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

# 检测当前 shell 类型
detect_shell() {
    local shell_name=""
    if [ -n "$ZSH_VERSION" ]; then
        shell_name="zsh"
    elif [ -n "$BASH_VERSION" ]; then
        shell_name="bash"
    else
        shell_name="unknown"
    fi
    echo "$shell_name"
}

# 获取 shell 配置文件路径
get_shell_config() {
    local shell_type="$1"
    local config_file=""
    
    case "$shell_type" in
        "zsh")
            if [ -f "$HOME/.zshrc" ]; then
                config_file="$HOME/.zshrc"
            elif [ -f "$HOME/.zprofile" ]; then
                config_file="$HOME/.zprofile"
            fi
            ;;
        "bash")
            if [ -f "$HOME/.bashrc" ]; then
                config_file="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                config_file="$HOME/.bash_profile"
            fi
            ;;
    esac
    
    echo "$config_file"
}

# 安装 dotf
install_dotconf() {
    local script_dir="$(get_script_dir)"
    local script_path="$script_dir/$DOTCONF_SCRIPT"
    
    if [ ! -f "$script_path" ]; then
        error "找不到 $DOTCONF_SCRIPT 脚本"
        exit 1
    fi
    
    # 添加执行权限
    chmod +x "$script_path"
    log "已设置执行权限"
    
    # 创建符号链接到 PATH
    local target_dir="/usr/local/bin"
    if [ ! -w "$target_dir" ]; then
        target_dir="$HOME/.local/bin"
        mkdir -p "$target_dir"
    fi
    
    local target="$target_dir/dotf"
    if [ -L "$target" ]; then
        rm "$target"
    fi
    
    ln -sf "$script_path" "$target"
    log "已创建符号链接: $target"
    
    # 添加到 PATH（如果不在）
    if [[ ":$PATH:" != *":$target_dir:"* ]]; then
        local current_shell="$(detect_shell)"
        local shell_config="$(get_shell_config "$current_shell")"
        
        if [ -n "$shell_config" ]; then
            # 检查是否已经添加过
            if ! grep -q "export PATH.*$target_dir" "$shell_config" 2>/dev/null; then
                echo "" >> "$shell_config"
                echo "# Dotf PATH" >> "$shell_config"
                echo "export PATH=\"$target_dir:\$PATH\"" >> "$shell_config"
                log "已添加 $target_dir 到 $shell_config"
            else
                log "PATH 已存在于 $shell_config"
            fi
        else
            warn "未找到 shell 配置文件，请手动添加: export PATH=\"$target_dir:\$PATH\""
        fi
    fi
}

# 初始化 dotfiles
init_dotfiles() {
    log "开始初始化 dotfiles..."
    
    if [ -d "$DOTFILES_REPO" ]; then
        warn "Dotfiles 目录已存在: $DOTFILES_REPO"
        read -p "是否重新初始化？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "跳过初始化"
            return 0
        fi
        rm -rf "$DOTFILES_REPO"
    fi
    
    # 运行初始化
    if command -v dotf >/dev/null 2>&1; then
        dotf init
    else
        "$(get_script_dir)/$DOTCONF_SCRIPT" init
    fi
}

# 显示使用说明
show_usage() {
    echo -e "${BLUE}Dotf 安装脚本 - 单仓库设计${NC}"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -f, --force    强制重新安装"
    echo "  --skip-init    跳过 dotfiles 初始化"
    echo ""
    echo "示例:"
    echo "  $0              # 正常安装"
    echo "  $0 -f           # 强制重新安装"
    echo "  $0 --skip-init  # 只安装脚本，不初始化"
    echo ""
    echo "设计特点:"
    echo "  - 单仓库管理，简化使用"
    echo "  - 自动符号链接管理"
    echo "  - 一键安装和初始化"
    echo "  - 兼容 bash 和 zsh"
    echo ""
}

# 主函数
main() {
    local force=false
    local skip_init=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -f|--force)
                force=true
                shift
                ;;
            --skip-init)
                skip_init=true
                shift
                ;;
            *)
                error "未知参数: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log "开始安装 Dotf (单仓库设计)..."
    log "检测到 shell: $(detect_shell)"
    
    # 检查依赖
    check_dependencies
    
    # 安装脚本
    install_dotconf
    
    # 初始化 dotfiles（除非跳过）
    if [ "$skip_init" = false ]; then
        init_dotfiles
    fi
    
    log "安装完成！"
    echo ""
    echo -e "${GREEN}下一步：${NC}"
    local current_shell="$(detect_shell)"
    local shell_config="$(get_shell_config "$current_shell")"
    if [ -n "$shell_config" ]; then
        echo "1. 重新加载 shell: source $shell_config"
    else
        echo "1. 重新加载 shell 或重启终端"
    fi
    echo "2. 使用命令: dotf --help"
    echo "3. 查看状态: dotf status"
    echo ""
    echo -e "${BLUE}单仓库设计优势：${NC}"
    echo "• 只需要一个仓库管理所有配置"
    echo "• 自动创建符号链接"
    echo "• 简化同步和冲突处理"
    echo "• 更直观的文件组织"
    echo "• 兼容 bash 和 zsh 环境"
    echo ""
    echo -e "${BLUE}更多信息请查看 README.md${NC}"
}

# 执行主函数
main "$@" 