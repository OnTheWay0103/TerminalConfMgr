#!/bin/bash
# TerminalConfigMgr 安全部署脚本
# 高优先级：保护新电脑部署安全

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置变量
BACKUP_DIR="$HOME/.config_backups"
DEPLOY_LOG="$HOME/.dotconf_deploy.log"
FORCE_BACKUP=false
DRY_RUN=false

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$DEPLOY_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$DEPLOY_LOG" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$DEPLOY_LOG"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$DEPLOY_LOG"
}

# 使用帮助
usage() {
    cat << EOF
TerminalConfigMgr 安全部署工具

用法: $0 [选项]

选项:
    --dry-run       预览将要执行的操作，不实际执行
    --force-backup  对所有配置文件强制创建备份
    --help          显示此帮助信息

示例:
    $0              # 标准安全部署
    $0 --dry-run    # 预览部署过程
    $0 --force-backup # 强制备份所有文件
EOF
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force-backup)
            FORCE_BACKUP=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            error "未知参数: $1"
            usage
            exit 1
            ;;
    esac
done

# 创建备份
create_backup() {
    local source_file="$1"
    local backup_name="$(basename "$source_file").backup.$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [[ -e "$source_file" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            info "将备份: $source_file → $backup_path"
            return 0
        fi
        
        mkdir -p "$BACKUP_DIR"
        cp -a "$source_file" "$backup_path"
        log "✅ 已备份: $source_file → $backup_path"
        return 0
    fi
    
    return 1
}

# 安全检查
run_security_check() {
    if [[ -f "tools/security_check.sh" ]]; then
        log "正在运行安全检查..."
        if ! bash tools/security_check.sh; then
            error "安全检查未通过，部署已中止"
            exit 1
        fi
    else
        warning "安全检查脚本未找到，跳过安全检查"
    fi
}

# 系统兼容性检查
check_compatibility() {
    log "正在检查系统兼容性..."
    
    local os_type=$(uname -s)
    case "$os_type" in
        Darwin*)
            info "检测到 macOS"
            ;;
        Linux*)
            info "检测到 Linux"
            ;;
        *)
            warning "未测试的操作系统: $os_type，继续部署但请谨慎"
            ;;
    esac
    
    # 检查必需工具
    local required_tools=("git" "bash" "zsh")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            error "缺少必需工具: $tool"
            exit 1
        fi
    done
    
    log "✅ 系统兼容性检查通过"
}

# 预览将要修改的文件
preview_changes() {
    log "预览将要修改的文件..."
    
    local configs_dir="configs"
    local target_files=()
    
    # 收集所有配置文件
    while IFS= read -r -d '' file; do
        local basename_file=$(basename "$file")
        local target_path="$HOME/$basename_file"
        
        if [[ -e "$target_path" ]] || [[ "$FORCE_BACKUP" == true ]]; then
            target_files+=("$target_path")
        fi
    done < <(find "$configs_dir" -type f -print0)
    
    if [[ ${#target_files[@]} -eq 0 ]]; then
        info "未发现需要备份的现有配置文件"
    else
        info "发现以下配置文件将被处理："
        for file in "${target_files[@]}"; do
            info "  - $file"
        done
    fi
}

# 交互式确认
interactive_confirm() {
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi
    
    echo
    warning "⚠️  即将开始配置部署"
    echo "此操作将会："
    echo "  1. 创建现有配置文件备份"
    echo "  2. 建立符号链接到配置文件"
    echo "  3. 修改您的shell环境"
    echo
    
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "用户取消部署"
        exit 0
    fi
}

# 创建系统快照
create_system_snapshot() {
    log "正在创建系统快照..."
    
    local snapshot_dir="$BACKUP_DIR/snapshot_$(date +%Y%m%d_%H%M%S)"
    
    if [[ "$DRY_RUN" == true ]]; then
        info "将创建系统快照于: $snapshot_dir"
        return 0
    fi
    
    mkdir -p "$snapshot_dir"
    
    # 备份关键配置文件
    local important_configs=(".zshrc" ".bashrc" ".vimrc" ".gitconfig")
    for config in "${important_configs[@]}"; do
        local config_path="$HOME/$config"
        if [[ -e "$config_path" ]]; then
            cp -a "$config_path" "$snapshot_dir/"
            log "✅ 已备份: $config_path"
        fi
    done
    
    info "系统快照已创建: $snapshot_dir"
}

# 部署配置文件
deploy_configs() {
    log "正在部署配置文件..."
    
    local repo_dir="$(pwd)"
    local configs_dir="$repo_dir/configs"
    
    # 处理每个配置文件
    while IFS= read -r -d '' source_file; do
        local basename_file=$(basename "$source_file")
        local target_path="$HOME/$basename_file"
        
        # 创建备份
        create_backup "$target_path"
        
        if [[ "$DRY_RUN" == true ]]; then
            info "将创建符号链接: $source_file → $target_path"
            continue
        fi
        
        # 创建符号链接
        if [[ -L "$target_path" ]]; then
            rm "$target_path"
        elif [[ -e "$target_path" ]]; then
            mv "$target_path" "$target_path.old"
        fi
        
        ln -sf "$source_file" "$target_path"
        log "✅ 已链接: $basename_file"
        
    done < <(find "$configs_dir" -type f -print0)
}

# 验证部署
verify_deployment() {
    log "正在验证部署..."
    
    local success=true
    local configs_dir="configs"
    
    while IFS= read -r -d '' source_file; do
        local basename_file=$(basename "$source_file")
        local target_path="$HOME/$basename_file"
        
        if [[ "$DRY_RUN" == true ]]; then
            info "将验证: $target_path"
            continue
        fi
        
        if [[ ! -L "$target_path" ]]; then
            error "符号链接未创建: $target_path"
            success=false
        elif [[ "$(readlink "$target_path")" != "$source_file" ]]; then
            error "符号链接指向错误: $target_path"
            success=false
        fi
    done < <(find "$configs_dir" -type f -print0)
    
    if [[ "$success" == true ]]; then
        log "✅ 部署验证通过"
    else
        error "部署验证失败"
        return 1
    fi
}

# 创建恢复脚本
create_recovery_script() {
    local recovery_script="$BACKUP_DIR/recovery_$(date +%Y%m%d_%H%M%S).sh"
    
    if [[ "$DRY_RUN" == true ]]; then
        info "将创建恢复脚本: $recovery_script"
        return 0
    fi
    
    cat > "$recovery_script" << 'EOF'
#!/bin/bash
# TerminalConfigMgr 恢复脚本
# 运行此脚本将移除所有符号链接并恢复原始文件

set -euo pipefail

echo "🚨 正在恢复原始配置..."

# 恢复备份文件
backup_dir="$(dirname "$0")"
for backup_file in "$backup_dir"/*.backup.*; do
    if [[ -f "$backup_file" ]]; then
        local original_name=$(basename "$backup_file" | sed 's/\.backup\..*//')
        local target_path="$HOME/$original_name"
        
        if [[ -L "$target_path" ]]; then
            rm "$target_path"
        fi
        
        cp "$backup_file" "$target_path"
        echo "✅ 已恢复: $original_name"
    fi
done

echo "✅ 恢复完成！请重启终端或重新加载配置。"
EOF
    
    chmod +x "$recovery_script"
    log "✅ 恢复脚本已创建: $recovery_script"
}

# 主部署流程
main() {
    log "开始TerminalConfigMgr安全部署..."
    
    # 执行安全检查
    run_security_check
    check_compatibility
    
    # 预览和确认
    preview_changes
    interactive_confirm
    
    # 执行部署
    create_system_snapshot
    deploy_configs
    verify_deployment
    create_recovery_script
    
    if [[ "$DRY_RUN" == false ]]; then
        log "✅ 安全部署完成！"
        log "备份位置: $BACKUP_DIR"
        log "如需恢复，请运行: $BACKUP_DIR/recovery_*.sh"
    else
        log "📋 干运行完成，未进行实际更改"
    fi
}

# 运行主函数
main "$@"