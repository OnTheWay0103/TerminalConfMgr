#!/bin/bash

# 配置文件安装脚本
# 在覆盖配置文件时自动备份

# 导入自动备份工具
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tools/simple_backup.sh"

# 配置映射（源文件 -> 目标文件）
CONFIG_MAP=(
    "configs/.zshrc:${HOME}/.zshrc"
    "configs/.zshrc_custom:${HOME}/.zshrc_custom"
    "configs/.vimrc:${HOME}/.vimrc"
    "configs/.gitconfig:${HOME}/.gitconfig"
    "configs/.gitignore_global:${HOME}/.gitignore_global"
)

# 安装单个配置文件
install_config() {
    local src="$1"
    local dst="$2"
    local description="安装配置文件"
    
    # 检查源文件是否存在
    if [ ! -f "$src" ]; then
        echo "⚠️  源文件不存在: $src"
        return 1
    fi
    
    # 安全复制（自动备份）
    safe_cp "$src" "$dst" "$description"
}

# 安装所有配置文件
install_all_configs() {
    echo "🔧 开始安装配置文件..."
    echo "📁 项目目录: $SCRIPT_DIR"
    echo ""
    
    local success_count=0
    local total_count=0
    
    for config_pair in "${CONFIG_MAP[@]}"; do
        IFS=':' read -r src dst <<< "$config_pair"
        total_count=$((total_count + 1))
        
        echo "📝 安装: $src -> $dst"
        if install_config "$src" "$dst"; then
            success_count=$((success_count + 1))
        fi
        echo ""
    done
    
    echo "✅ 安装完成: $success_count/$total_count 个配置文件"
}

# 安装特定配置文件
install_specific_config() {
    local config_name="$1"
    
    for config_pair in "${CONFIG_MAP[@]}"; do
        IFS=':' read -r src dst <<< "$config_pair"
        if [[ "$src" == *"$config_name"* ]]; then
            echo "📝 安装特定配置: $config_name"
            install_config "$src" "$dst"
            return 0
        fi
    done
    
    echo "❌ 未找到配置文件: $config_name"
    return 1
}

# 显示配置列表
list_configs() {
    echo "📋 可用的配置文件:"
    echo "=================="
    
    for config_pair in "${CONFIG_MAP[@]}"; do
        IFS=':' read -r src dst <<< "$config_pair"
        local status=""
        
        if [ -f "$src" ]; then
            status="✅"
        else
            status="❌"
        fi
        
        echo "$status $src -> $dst"
    done
}

# 显示帮助
show_help() {
    echo "🔧 配置文件安装工具"
    echo ""
    echo "用法:"
    echo "  $0 [选项] [配置文件名]"
    echo ""
    echo "选项:"
    echo "  install [配置文件名]  - 安装配置文件（默认安装所有）"
    echo "  list                   - 显示可用的配置文件"
    echo "  help                   - 显示此帮助"
    echo ""
    echo "示例:"
    echo "  $0 install             - 安装所有配置文件"
    echo "  $0 install .zshrc      - 只安装 .zshrc"
    echo "  $0 list                - 查看可用配置"
    echo ""
    echo "注意:"
    echo "  - 安装前会自动备份现有配置文件"
    echo "  - 备份文件保存在 ~/.config_backups/ 目录"
}

# 主函数
main() {
    case "${1:-install}" in
        "install")
            if [ -n "$2" ]; then
                install_specific_config "$2"
            else
                install_all_configs
            fi
            ;;
        "list")
            list_configs
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