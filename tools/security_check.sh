#!/bin/bash
# TerminalConfigMgr 安全检查脚本
# 高优先级安全功能

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查敏感数据
check_sensitive_data() {
    log "正在检查敏感数据..."
    
    local sensitive_patterns=(
        "api_key"
        "apikey"
        "secret"
        "password"
        "token"
        "sk-[a-zA-Z0-9]{20,}"
        "AKIA[0-9A-Z]{16}"
    )
    
    local found_sensitive=false
    
    for pattern in "${sensitive_patterns[@]}"; do
        if grep -ri "$pattern" configs/ 2>/dev/null; then
            error "发现敏感数据匹配模式: $pattern"
            found_sensitive=true
        fi
    done
    
    if [ "$found_sensitive" = true ]; then
        error "发现敏感数据，请先处理后再部署"
        return 1
    else
        log "✅ 未发现敏感数据"
    fi
}

# 检查文件权限
check_file_permissions() {
    log "正在检查文件权限..."
    
    local config_files=(
        "configs/.zshrc"
        "configs/.zshrc_custom"
        "configs/.bashrc"
    )
    
    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            local perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%A" "$file" 2>/dev/null)
            if [[ "$perms" != "600" && "$perms" != "644" ]]; then
                warning "配置文件 $file 权限过于宽松: $perms"
                chmod 600 "$file"
                log "已修复 $file 权限为 600"
            fi
        fi
    done
    
    log "✅ 文件权限检查完成"
}

# 检查必需工具
check_dependencies() {
    log "正在检查必需工具..."
    
    local required_tools=("git" "curl" "zsh" "bash")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        error "缺少必需工具: ${missing_tools[*]}"
        return 1
    else
        log "✅ 所有必需工具已安装"
    fi
}

# 检查Git配置
check_git_config() {
    log "正在检查Git配置..."
    
    if ! git config --get user.name >/dev/null 2>&1; then
        error "Git用户名未配置"
        return 1
    fi
    
    if ! git config --get user.email >/dev/null 2>&1; then
        error "Git邮箱未配置"
        return 1
    fi
    
    log "✅ Git配置检查完成"
}

# 安全检查主函数
main() {
    log "开始TerminalConfigMgr安全检查..."
    
    local exit_code=0
    
    # 执行各项检查
    check_sensitive_data || exit_code=1
    check_file_permissions || exit_code=1
    check_dependencies || exit_code=1
    check_git_config || exit_code=1
    
    if [ $exit_code -eq 0 ]; then
        log "✅ 所有安全检查通过，可以安全部署"
    else
        error "存在安全问题，请先解决上述问题"
    fi
    
    return $exit_code
}

# 如果直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi