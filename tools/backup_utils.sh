#!/bin/bash

# 备份工具函数
# 用于在修改配置文件前自动创建备份

# 配置备份目录
BACKUP_DIR="${HOME}/.config_backups"
MAX_BACKUPS=10  # 保留的最大备份数量

# 创建备份目录
ensure_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "✅ 创建备份目录: $BACKUP_DIR"
    fi
}

# 生成备份文件名
generate_backup_name() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    echo "${file_name}.backup.${timestamp}"
}

# 创建文件备份
backup_file() {
    local file_path="$1"
    local description="${2:-自动备份}"
    
    if [ ! -f "$file_path" ]; then
        echo "⚠️  文件不存在: $file_path"
        return 1
    fi
    
    ensure_backup_dir
    
    local backup_name=$(generate_backup_name "$file_path")
    local backup_path="$BACKUP_DIR/$backup_name"
    
    # 创建备份
    cp "$file_path" "$backup_path"
    
    # 添加备份信息
    echo "# 备份信息" >> "$backup_path"
    echo "# 原文件: $file_path" >> "$backup_path"
    echo "# 备份时间: $(date)" >> "$backup_path"
    echo "# 描述: $description" >> "$backup_path"
    echo "# 备份文件: $backup_path" >> "$backup_path"
    
    echo "✅ 已备份: $file_path -> $backup_path"
    
    # 清理旧备份
    cleanup_old_backups "$(basename "$file_path")"
    
    return 0
}

# 清理旧备份文件
cleanup_old_backups() {
    local file_pattern="$1"
    
    if [ -z "$file_pattern" ]; then
        return
    fi
    
    # 按修改时间排序，保留最新的MAX_BACKUPS个备份
    local old_backups=$(find "$BACKUP_DIR" -name "${file_pattern}.backup.*" -type f -exec stat -f '%m %N' {} \; | sort -n | head -n -$MAX_BACKUPS | cut -d' ' -f2-)
    
    if [ -n "$old_backups" ]; then
        echo "$old_backups" | xargs rm -f
        echo "🧹 已清理 $(echo "$old_backups" | wc -l) 个旧备份文件"
    fi
}

# 列出备份文件
list_backups() {
    local file_pattern="${1:-*}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "📁 备份目录不存在: $BACKUP_DIR"
        return
    fi
    
    echo "📋 备份文件列表 ($BACKUP_DIR):"
    echo "----------------------------------------"
    
    find "$BACKUP_DIR" -name "${file_pattern}.backup.*" -type f -exec stat -f '%m %N' {} \; | sort -n | while read timestamp file; do
        local date_str=$(date -r "${timestamp%.*}" '+%Y-%m-%d %H:%M:%S')
        echo "$date_str - $(basename "$file")"
    done
}

# 恢复备份文件
restore_backup() {
    local backup_file="$1"
    local target_file="$2"
    
    if [ ! -f "$backup_file" ]; then
        echo "❌ 备份文件不存在: $backup_file"
        return 1
    fi
    
    # 创建目标文件的备份（以防万一）
    if [ -f "$target_file" ]; then
        backup_file "$target_file" "恢复前的备份"
    fi
    
    # 恢复文件
    cp "$backup_file" "$target_file"
    echo "✅ 已恢复: $backup_file -> $target_file"
}

# 显示使用帮助
show_help() {
    echo "🔧 配置文件备份工具"
    echo ""
    echo "用法:"
    echo "  $0 backup <文件路径> [描述]     - 备份指定文件"
    echo "  $0 list [文件模式]             - 列出备份文件"
    echo "  $0 restore <备份文件> <目标文件> - 恢复备份文件"
    echo "  $0 help                        - 显示此帮助"
    echo ""
    echo "示例:"
    echo "  $0 backup ~/.zshrc_custom 'SSH配置修改前备份'"
    echo "  $0 list .zshrc_custom"
    echo "  $0 restore ~/.config_backups/.zshrc_custom.backup.20240712_191100 ~/.zshrc_custom"
}

# 主函数
main() {
    case "${1:-help}" in
        "backup")
            if [ -z "$2" ]; then
                echo "❌ 请指定要备份的文件路径"
                exit 1
            fi
            backup_file "$2" "$3"
            ;;
        "list")
            list_backups "$2"
            ;;
        "restore")
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo "❌ 请指定备份文件和目标文件"
                exit 1
            fi
            restore_backup "$2" "$3"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 