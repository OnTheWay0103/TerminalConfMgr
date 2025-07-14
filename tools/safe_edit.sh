#!/bin/bash

# 安全的文件编辑工具
# 在修改文件前自动创建备份

# 导入备份工具
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/backup_utils.sh"

# 安全地修改文件
safe_edit_file() {
    local file_path="$1"
    local description="${2:-文件修改}"
    local edit_function="$3"
    
    echo "🔧 准备修改文件: $file_path"
    
    # 检查文件是否存在
    if [ ! -f "$file_path" ]; then
        echo "❌ 文件不存在: $file_path"
        return 1
    fi
    
    # 创建备份
    if ! backup_file "$file_path" "$description"; then
        echo "❌ 备份失败，取消修改"
        return 1
    fi
    
    # 执行修改
    if [ -n "$edit_function" ] && type "$edit_function" >/dev/null 2>&1; then
        echo "📝 执行修改函数: $edit_function"
        "$edit_function" "$file_path"
    else
        echo "📝 请手动修改文件: $file_path"
        echo "💡 备份已创建，可以安全修改"
    fi
    
    echo "✅ 文件修改完成"
}

# 安全地替换文件内容
safe_replace_file() {
    local file_path="$1"
    local new_content="$2"
    local description="${3:-内容替换}"
    
    echo "🔧 准备替换文件内容: $file_path"
    
    # 创建备份
    if ! backup_file "$file_path" "$description"; then
        echo "❌ 备份失败，取消替换"
        return 1
    fi
    
    # 替换文件内容
    echo "$new_content" > "$file_path"
    
    echo "✅ 文件内容已替换"
}

# 安全地追加内容到文件
safe_append_file() {
    local file_path="$1"
    local content="$2"
    local description="${3:-内容追加}"
    
    echo "🔧 准备追加内容到文件: $file_path"
    
    # 创建备份
    if ! backup_file "$file_path" "$description"; then
        echo "❌ 备份失败，取消追加"
        return 1
    fi
    
    # 追加内容
    echo "$content" >> "$file_path"
    
    echo "✅ 内容已追加到文件"
}

# 安全地搜索替换
safe_search_replace() {
    local file_path="$1"
    local search_pattern="$2"
    local replace_pattern="$3"
    local description="${4:-搜索替换}"
    
    echo "🔧 准备搜索替换: $file_path"
    
    # 创建备份
    if ! backup_file "$file_path" "$description"; then
        echo "❌ 备份失败，取消搜索替换"
        return 1
    fi
    
    # 检查是否包含搜索模式
    if ! grep -q "$search_pattern" "$file_path"; then
        echo "⚠️  文件中未找到搜索模式: $search_pattern"
        return 1
    fi
    
    # 执行搜索替换
    sed -i.bak "s/$search_pattern/$replace_pattern/g" "$file_path"
    rm -f "$file_path.bak"  # 删除sed创建的临时备份
    
    echo "✅ 搜索替换完成"
}

# 显示使用帮助
show_help() {
    echo "🔧 安全文件编辑工具"
    echo ""
    echo "用法:"
    echo "  $0 edit <文件路径> [描述] [编辑函数]     - 安全编辑文件"
    echo "  $0 replace <文件路径> <新内容> [描述]    - 安全替换文件内容"
    echo "  $0 append <文件路径> <内容> [描述]       - 安全追加内容"
    echo "  $0 search <文件路径> <搜索> <替换> [描述] - 安全搜索替换"
    echo "  $0 backup <文件路径> [描述]              - 备份文件"
    echo "  $0 list [文件模式]                       - 列出备份"
    echo "  $0 restore <备份文件> <目标文件>         - 恢复备份"
    echo "  $0 help                                  - 显示此帮助"
    echo ""
    echo "示例:"
    echo "  $0 edit ~/.zshrc_custom 'SSH配置修改'"
    echo "  $0 replace ~/.zshrc_custom '新的配置内容' '配置更新'"
    echo "  $0 append ~/.zshrc_custom 'export NEW_VAR=value' '添加环境变量'"
}

# 主函数
main() {
    case "${1:-help}" in
        "edit")
            if [ -z "$2" ]; then
                echo "❌ 请指定要编辑的文件路径"
                exit 1
            fi
            safe_edit_file "$2" "$3" "$4"
            ;;
        "replace")
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo "❌ 请指定文件路径和新内容"
                exit 1
            fi
            safe_replace_file "$2" "$3" "$4"
            ;;
        "append")
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo "❌ 请指定文件路径和追加内容"
                exit 1
            fi
            safe_append_file "$2" "$3" "$4"
            ;;
        "search")
            if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
                echo "❌ 请指定文件路径、搜索模式和替换模式"
                exit 1
            fi
            safe_search_replace "$2" "$3" "$4" "$5"
            ;;
        "backup")
            backup_file "$2" "$3"
            ;;
        "list")
            list_backups "$2"
            ;;
        "restore")
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