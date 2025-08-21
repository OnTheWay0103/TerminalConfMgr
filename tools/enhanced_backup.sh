#!/bin/bash
# TerminalConfigMgr 增强备份回滚系统
# 高优先级：确保数据安全和快速恢复

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_DIR="$HOME/.config_backups"
SNAPSHOT_DIR="$BACKUP_DIR/snapshots"
RECOVERY_LOG="$BACKUP_DIR/recovery.log"

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$RECOVERY_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$RECOVERY_LOG" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$RECOVERY_LOG"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$RECOVERY_LOG"
}

# 创建完整系统快照
create_snapshot() {
    local snapshot_name="snapshot_$(date +%Y%m%d_%H%M%S)"
    local snapshot_path="$SNAPSHOT_DIR/$snapshot_name"
    
    mkdir -p "$snapshot_path"
    
    # 备份关键配置
    local important_configs=(
        ".zshrc"
        ".bashrc"
        ".vimrc"
        ".gitconfig"
        ".tmux.conf"
        ".ssh/config"
        ".config/nvim"
        ".config/git"
    )
    
    log "正在创建系统快照: $snapshot_name"
    
    for config in "${important_configs[@]}"; do
        local source_path="$HOME/$config"
        if [[ -e "$source_path" ]]; then
            if [[ -d "$source_path" ]]; then
                cp -r "$source_path" "$snapshot_path/"
            else
                cp "$source_path" "$snapshot_path/"
            fi
            log "✅ 已备份: $config"
        fi
    done
    
    # 创建快照元数据
    cat > "$snapshot_path/metadata.json" << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "hostname": "$(hostname)",
    "user": "$(whoami)",
    "system": "$(uname -s)",
    "version": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')"
}
EOF
    
    log "✅ 系统快照创建完成: $snapshot_path"
    echo "$snapshot_path"
}

# 列出可用备份
list_backups() {
    log "可用备份和快照:"
    
    # 列出快照
    if [[ -d "$SNAPSHOT_DIR" ]]; then
        info "系统快照:"
        find "$SNAPSHOT_DIR" -maxdepth 1 -type d -name "snapshot_*" | sort -r | while read -r snapshot; do
            if [[ -f "$snapshot/metadata.json" ]]; then
                local timestamp=$(grep "timestamp" "$snapshot/metadata.json" | cut -d'"' -f4)
                local hostname=$(grep "hostname" "$snapshot/metadata.json" | cut -d'"' -f4)
                printf "  📦 %s (%s)\n" "$(basename "$snapshot")" "$hostname"
            fi
        done
    fi
    
    # 列出单个文件备份
    if [[ -d "$BACKUP_DIR" ]]; then
        info "文件备份:"
        find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.backup.*" | sort -r | head -10 | while read -r backup; do
            printf "  📄 %s\n" "$(basename "$backup")"
        done
    fi
}

# 智能恢复
smart_restore() {
    local target="${1:-latest}"
    
    if [[ "$target" == "latest" ]]; then
        # 找到最新的快照
        target=$(find "$SNAPSHOT_DIR" -maxdepth 1 -type d -name "snapshot_*" | sort -r | head -1)
        if [[ -z "$target" ]]; then
            error "未找到可用快照"
            return 1
        fi
    fi
    
    if [[ ! -d "$target" ]]; then
        error "快照不存在: $target"
        return 1
    fi
    
    log "正在从快照恢复: $(basename "$target")"
    
    # 创建恢复前快照
    local pre_restore_snapshot=$(create_snapshot)
    log "✅ 已创建恢复前快照: $(basename "$pre_restore_snapshot")"
    
    # 执行恢复
    while IFS= read -r -d '' file; do
        local relative_path=${file#$target/}
        local target_path="$HOME/$relative_path"
        
        if [[ -e "$file" ]]; then
            # 创建目标目录
            mkdir -p "$(dirname "$target_path")"
            
            # 备份当前文件
            if [[ -e "$target_path" ]]; then
                create_backup "$target_path"
            fi
            
            # 恢复文件
            cp -a "$file" "$target_path"
            log "✅ 已恢复: $relative_path"
        fi
    done < <(find "$target" -type f ! -name "metadata.json" -print0)
    
    log "✅ 恢复完成，恢复前快照: $pre_restore_snapshot"
}

# 选择性恢复
selective_restore() {
    local backup_file="$1"
    local target_path="${2:-$HOME/$(basename "$backup_file" | sed 's/\.backup\..*//')}"
    
    if [[ ! -f "$backup_file" ]]; then
        error "备份文件不存在: $backup_file"
        return 1
    fi
    
    # 创建当前文件备份
    if [[ -e "$target_path" ]]; then
        create_backup "$target_path"
    fi
    
    # 恢复文件
    cp "$backup_file" "$target_path"
    log "✅ 已恢复文件: $target_path"
}

# 创建差异备份
create_diff_backup() {
    local reference_snapshot="$1"
    local diff_backup_name="diff_$(basename "$reference_snapshot")_$(date +%Y%m%d_%H%M%S)"
    local diff_backup_path="$BACKUP_DIR/$diff_backup_name"
    
    if [[ ! -d "$reference_snapshot" ]]; then
        error "参考快照不存在: $reference_snapshot"
        return 1
    fi
    
    mkdir -p "$diff_backup_path"
    
    # 创建差异备份（只备份有变化的文件）
    log "正在创建差异备份: $diff_backup_name"
    
    while IFS= read -r -d '' source_file; do
        local relative_path=${source_file#$reference_snapshot/}
        local current_file="$HOME/$relative_path"
        
        if [[ -f "$current_file" ]]; then
            if ! cmp -s "$source_file" "$current_file"; then
                cp "$current_file" "$diff_backup_path/"
                log "✅ 已备份变化文件: $relative_path"
            fi
        elif [[ -f "$source_file" ]]; then
            # 文件已被删除，创建删除标记
            touch "$diff_backup_path/$relative_path.deleted"
            log "📋 标记已删除文件: $relative_path"
        fi
    done < <(find "$reference_snapshot" -type f ! -name "metadata.json" -print0)
    
    log "✅ 差异备份创建完成: $diff_backup_path"
}

# 自动清理旧备份
cleanup_old_backups() {
    local retention_days="${1:-30}"
    
    log "正在清理超过 $retention_days 天的旧备份..."
    
    # 清理旧快照
    find "$SNAPSHOT_DIR" -maxdepth 1 -type d -name "snapshot_*" -mtime +$retention_days -exec rm -rf {} \; 2>/dev/null || true
    
    # 清理旧文件备份
    find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.backup.*" -mtime +$retention_days -delete 2>/dev/null || true
    
    log "✅ 旧备份清理完成"
}

# 紧急回滚
emergency_rollback() {
    log "🚨 执行紧急回滚..."
    
    # 找到最新的快照
    local latest_snapshot=$(find "$SNAPSHOT_DIR" -maxdepth 1 -type d -name "snapshot_*" | sort -r | head -1)
    
    if [[ -n "$latest_snapshot" ]]; then
        smart_restore "$latest_snapshot"
    else
        error "未找到可用快照进行回滚"
        return 1
    fi
}

# 验证备份完整性
verify_backup() {
    local target="${1:-latest}"
    
    if [[ "$target" == "latest" ]]; then
        target=$(find "$SNAPSHOT_DIR" -maxdepth 1 -type d -name "snapshot_*" | sort -r | head -1)
    fi
    
    if [[ ! -d "$target" ]]; then
        error "备份不存在: $target"
        return 1
    fi
    
    log "正在验证备份完整性: $(basename "$target")"
    
    local issues=0
    while IFS= read -r -d '' file; do
        if [[ ! -r "$file" ]]; then
            error "无法读取备份文件: $(basename "$file")"
            ((issues++))
        fi
    done < <(find "$target" -type f ! -name "metadata.json" -print0)
    
    if [[ $issues -eq 0 ]]; then
        log "✅ 备份完整性验证通过"
    else
        error "备份存在 $issues 个问题"
        return 1
    fi
}

# 使用帮助
usage() {
    cat << EOF
TerminalConfigMgr 增强备份回滚系统

用法: $0 [命令] [参数]

命令:
    snapshot                    创建完整系统快照
    list                        列出所有可用备份
    restore [snapshot]          从快照恢复（默认最新）
    selective [backup] [target] 选择性恢复单个文件
    diff [snapshot]             创建差异备份
    cleanup [days]              清理旧备份（默认30天）
    rollback                    紧急回滚到最新快照
    verify [snapshot]           验证备份完整性

示例:
    $0 snapshot                 # 创建系统快照
    $0 restore                  # 恢复到最新快照
    $0 restore snapshot_20240821_143022
    $0 selective .zshrc.backup.20240821_143022 ~/.zshrc
    $0 cleanup 7                # 清理7天前的备份
EOF
}

# 主函数
main() {
    case "${1:-help}" in
        "snapshot")
            create_snapshot
            ;;
        "list")
            list_backups
            ;;
        "restore")
            smart_restore "${2:-latest}"
            ;;
        "selective")
            if [[ $# -lt 2 ]]; then
                error "用法: $0 selective [backup_file] [target_path]"
                exit 1
            fi
            selective_restore "$2" "${3:-}"
            ;;
        "diff")
            if [[ $# -lt 2 ]]; then
                error "用法: $0 diff [reference_snapshot]"
                exit 1
            fi
            create_diff_backup "$2"
            ;;
        "cleanup")
            cleanup_old_backups "${2:-30}"
            ;;
        "rollback")
            emergency_rollback
            ;;
        "verify")
            verify_backup "${2:-latest}"
            ;;
        "help"|*)
            usage
            ;;
    esac
}

# 如果直接运行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi