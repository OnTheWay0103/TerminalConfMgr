#!/bin/bash

# 简单自动备份工具
# 只在覆盖配置文件时自动备份

# 导入备份工具
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/backup_utils.sh" ]; then
    source "$SCRIPT_DIR/backup_utils.sh"
else
    echo "⚠️  备份工具未找到: $SCRIPT_DIR/backup_utils.sh"
fi

# 需要自动备份的文件模式
BACKUP_PATTERNS=(
    ".*rc"
    ".*config"
    "*.conf"
    "*.sh"
    "*.py"
    "*.json"
    "*.yaml"
    "*.yml"
)

# 判断是否需要备份
should_backup() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    
    # 排除备份文件本身
    if [[ "$file_name" == *.backup.* ]]; then
        return 1
    fi
    
    # 检查是否匹配备份模式
    for pattern in "${BACKUP_PATTERNS[@]}"; do
        if [[ "$file_name" == $pattern ]]; then
            return 0
        fi
    done
    
    return 1
}

# 自动备份函数（在覆盖文件前调用）
auto_backup() {
    local file_path="$1"
    local description="${2:-自动备份}"
    
    # 检查文件是否存在
    if [ ! -f "$file_path" ]; then
        return 0  # 新文件，不需要备份
    fi
    
    # 检查是否需要备份
    if ! should_backup "$file_path"; then
        return 0  # 不需要备份的文件
    fi
    
    # 创建备份
    echo "📝 自动备份: $file_path"
    backup_file "$file_path" "$description"
}

# 安全的复制函数
safe_cp() {
    local src="$1"
    local dst="$2"
    local description="${3:-文件复制}"
    
    # 如果目标文件存在且需要备份，先备份
    if [ -f "$dst" ]; then
        auto_backup "$dst" "$description"
    fi
    
    # 执行复制
    cp "$src" "$dst"
    echo "✅ 已复制: $src -> $dst"
}

# 安全的移动函数
safe_mv() {
    local src="$1"
    local dst="$2"
    local description="${3:-文件移动}"
    
    # 如果目标文件存在且需要备份，先备份
    if [ -f "$dst" ]; then
        auto_backup "$dst" "$description"
    fi
    
    # 执行移动
    mv "$src" "$dst"
    echo "✅ 已移动: $src -> $dst"
}

# 安全的写入函数
safe_write() {
    local file_path="$1"
    local content="$2"
    local description="${3:-内容写入}"
    
    # 如果文件存在且需要备份，先备份
    if [ -f "$file_path" ]; then
        auto_backup "$file_path" "$description"
    fi
    
    # 写入内容
    echo "$content" > "$file_path"
    echo "✅ 已写入: $file_path"
}

# 安全的追加函数
safe_append() {
    local file_path="$1"
    local content="$2"
    local description="${3:-内容追加}"
    
    # 如果文件存在且需要备份，先备份
    if [ -f "$file_path" ]; then
        auto_backup "$file_path" "$description"
    fi
    
    # 追加内容
    echo "$content" >> "$file_path"
    echo "✅ 已追加: $file_path"
}

# 显示使用帮助
show_help() {
    echo "🔧 简单自动备份工具"
    echo ""
    echo "用法:"
    echo "  source tools/simple_backup.sh"
    echo ""
    echo "函数:"
    echo "  auto_backup <文件路径> [描述]     - 自动备份文件"
    echo "  safe_cp <源文件> <目标文件> [描述] - 安全复制"
    echo "  safe_mv <源文件> <目标文件> [描述] - 安全移动"
    echo "  safe_write <文件路径> <内容> [描述] - 安全写入"
    echo "  safe_append <文件路径> <内容> [描述] - 安全追加"
    echo ""
    echo "示例:"
    echo "  safe_cp configs/.zshrc_custom ~/.zshrc_custom '安装配置'"
    echo "  safe_write ~/.zshrc_local 'export NEW_VAR=value' '添加环境变量'"
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_help
fi 