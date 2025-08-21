#!/usr/bin/env bash
# TerminalConfigMgr 核心工具集合
# 整合所有核心功能到单一脚本

set -euo pipefail

# 配置
DOTFILES_REPO="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="${HOME}/.config_backups"
LOG_FILE="${HOME}/.dotconf.log"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE" >&2
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

# 创建备份
backup_file() {
    local source="$1"
    local backup_name="$(basename "$source").backup.$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    [[ -e "$source" ]] || return 0
    
    mkdir -p "$BACKUP_DIR"
    cp -a "$source" "$backup_path"
    echo "$backup_path"
}

# 安全部署
deploy_configs() {
    log "开始安全部署..."
    
    local configs_dir="$DOTFILES_REPO/configs"
    local count=0
    
    # 确保目录存在
    [[ -d "$configs_dir" ]] || {
        error "配置文件目录不存在: $configs_dir"
        return 1
    }
    
    # 处理每个配置文件
    for file in "$configs_dir"/*; do
        [[ -f "$file" ]] || continue
        
        local filename=$(basename "$file")
        local target="$HOME/$filename"
        
        # 备份现有文件
        local backup_path=$(backup_file "$target")
        [[ -n "$backup_path" ]] && log "已备份: $backup_path"
        
        # 创建符号链接
        [[ -e "$target" ]] && rm -f "$target"
        ln -sf "$file" "$target"
        log "已链接: $filename"
        ((count++))
    done
    
    log "✅ 部署完成，共处理 $count 个配置文件"
}

# 一键恢复
restore_all() {
    log "开始恢复原始配置..."
    
    local configs_dir="$DOTFILES_REPO/configs"
    local count=0
    
    for file in "$configs_dir"/*; do
        [[ -f "$file" ]] || continue
        
        local filename=$(basename "$file")
        local target="$HOME/$filename"
        
        # 移除符号链接
        if [[ -L "$target" ]]; then
            rm "$target"
            log "已移除: $filename"
            ((count++))
        fi
        
        # 恢复备份文件
        local latest_backup=$(find "$BACKUP_DIR" -name "$filename.backup.*" -type f | sort -r | head -1)
        if [[ -n "$latest_backup" ]]; then
            cp "$latest_backup" "$target"
            log "已恢复: $filename"
        fi
    done
    
    log "✅ 恢复完成，共处理 $count 个配置文件"
}

# 系统检查
check_system() {
    log "系统检查..."
    
    # 检查工具
    local tools=("git" "zsh" "bash")
    for tool in "${tools[@]}"; do
        command -v "$tool" >/dev/null || {
            error "缺少工具: $tool"
            return 1
        }
    done
    
    # 检查Git配置
    git config --get user.name >/dev/null || {
        error "Git用户名未配置"
        return 1
    }
    
    log "✅ 系统检查通过"
}

# 主函数
main() {
    case "${1:-help}" in
        "deploy")
            check_system && deploy_configs
            ;;
        "restore")
            restore_all
            ;;
        "check")
            check_system
            ;;
        "help"|*)
            cat << EOF
TerminalConfigMgr 核心工具

用法: $0 [命令]

命令:
    deploy      安全部署配置文件
    restore     恢复原始配置
    check       系统兼容性检查
    help        显示此帮助

示例:
    $0 deploy   # 部署配置
    $0 restore  # 恢复配置
    $0 check    # 检查系统
EOF
            ;;
    esac
}

# 运行主函数
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"