#!/bin/bash

# 自动备份监控器
# 监控指定目录的文件变化，自动创建备份

# 导入备份工具
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/backup_utils.sh"

# 配置
WATCH_DIRS=(
    "$HOME/.ssh"
    "$HOME"
    "./configs"
)
WATCH_PATTERNS=(
    "*.conf"
    ".*rc"
    ".*config"
    "*.sh"
    "*.py"
    "*.json"
    "*.yaml"
    "*.yml"
)
EXCLUDE_PATTERNS=(
    "*.backup.*"
    "*.tmp"
    "*.swp"
    "*~"
    ".DS_Store"
)

# 检查是否安装了fswatch
check_fswatch() {
    if ! command -v fswatch >/dev/null 2>&1; then
        echo "❌ fswatch 未安装，正在安装..."
        if command -v brew >/dev/null 2>&1; then
            brew install fswatch
        else
            echo "请手动安装 fswatch: https://github.com/emcrisostomo/fswatch"
            return 1
        fi
    fi
    return 0
}

# 构建监控模式
build_watch_patterns() {
    local patterns=""
    for pattern in "${WATCH_PATTERNS[@]}"; do
        if [ -n "$patterns" ]; then
            patterns="$patterns -o"
        fi
        patterns="$patterns -e '$pattern'"
    done
    echo "$patterns"
}

# 构建排除模式
build_exclude_patterns() {
    local excludes=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        excludes="$excludes -E '$pattern'"
    done
    echo "$excludes"
}

# 文件变化处理函数
handle_file_change() {
    local file_path="$1"
    local event_type="$2"
    
    # 检查文件是否存在且可读
    if [ ! -f "$file_path" ] || [ ! -r "$file_path" ]; then
        return
    fi
    
    # 检查是否应该备份此文件
    if ! should_backup_file "$file_path"; then
        return
    fi
    
    # 创建备份
    local description="自动备份 - $event_type"
    echo "📝 检测到文件变化: $file_path ($event_type)"
    
    if backup_file "$file_path" "$description"; then
        echo "✅ 自动备份完成: $file_path"
    else
        echo "⚠️  自动备份失败: $file_path"
    fi
}

# 判断是否应该备份文件
should_backup_file() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    
    # 排除备份文件本身
    if [[ "$file_name" == *.backup.* ]]; then
        return 1
    fi
    
    # 排除临时文件
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if [[ "$file_name" == $pattern ]]; then
            return 1
        fi
    done
    
    # 检查是否匹配监控模式
    for pattern in "${WATCH_PATTERNS[@]}"; do
        if [[ "$file_name" == $pattern ]]; then
            return 0
        fi
    done
    
    return 1
}

# 启动监控
start_monitoring() {
    echo "🔍 启动自动备份监控..."
    echo "📁 监控目录: ${WATCH_DIRS[*]}"
    echo "📋 监控模式: ${WATCH_PATTERNS[*]}"
    echo "🚫 排除模式: ${EXCLUDE_PATTERNS[*]}"
    echo ""
    
    # 构建fswatch命令
    local watch_patterns=$(build_watch_patterns)
    local exclude_patterns=$(build_exclude_patterns)
    
    # 启动fswatch监控
    for dir in "${WATCH_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo "👀 监控目录: $dir"
            fswatch -o "$dir" | while read num; do
                # 获取变化的文件列表
                fswatch -1 "$dir" | while read file; do
                    handle_file_change "$file" "modified"
                done
            done &
        else
            echo "⚠️  目录不存在: $dir"
        fi
    done
    
    echo "✅ 自动备份监控已启动"
    echo "💡 按 Ctrl+C 停止监控"
    
    # 等待用户中断
    wait
}

# 停止监控
stop_monitoring() {
    echo "🛑 停止自动备份监控..."
    pkill -f "fswatch.*$(basename "$0")" 2>/dev/null || true
    echo "✅ 监控已停止"
}

# 显示状态
show_status() {
    echo "📊 自动备份监控状态"
    echo "=================="
    
    # 检查fswatch进程
    if pgrep -f "fswatch" >/dev/null; then
        echo "✅ 监控进程运行中"
        ps aux | grep fswatch | grep -v grep
    else
        echo "❌ 监控进程未运行"
    fi
    
    echo ""
    echo "📁 备份目录: $BACKUP_DIR"
    if [ -d "$BACKUP_DIR" ]; then
        echo "📋 备份文件数量: $(find "$BACKUP_DIR" -name "*.backup.*" | wc -l)"
    else
        echo "📋 备份目录不存在"
    fi
}

# 显示帮助
show_help() {
    echo "🔧 自动备份监控器"
    echo ""
    echo "用法:"
    echo "  $0 start                    - 启动自动备份监控"
    echo "  $0 stop                     - 停止自动备份监控"
    echo "  $0 status                   - 显示监控状态"
    echo "  $0 help                     - 显示此帮助"
    echo ""
    echo "功能:"
    echo "  - 自动监控指定目录的文件变化"
    echo "  - 检测到变化时自动创建备份"
    echo "  - 支持多种文件类型和排除模式"
    echo "  - 自动清理旧备份文件"
    echo ""
    echo "配置:"
    echo "  监控目录: ${WATCH_DIRS[*]}"
    echo "  监控模式: ${WATCH_PATTERNS[*]}"
    echo "  排除模式: ${EXCLUDE_PATTERNS[*]}"
}

# 主函数
main() {
    case "${1:-help}" in
        "start")
            if ! check_fswatch; then
                exit 1
            fi
            start_monitoring
            ;;
        "stop")
            stop_monitoring
            ;;
        "status")
            show_status
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