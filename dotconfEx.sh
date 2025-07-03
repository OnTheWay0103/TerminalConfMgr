#!/usr/bin/env bash
# Terminal Configuration Manager v2.0 - Cross-Platform Dotfiles Sync
# Usage: 
#   init    : Initialize config repo
#   sync    : Push changes to remote
#   migrate : Set up on new machine
#   backup  : Create snapshot of current config
#   clean   : Clean up old backups
#   status  : Show current status

set -euo pipefail  # 严格错误处理

# 配置变量
DOTFILES_REPO="${DOTFILES_DIR:-$HOME/.dotfiles}"
CONFIG_PROFILE="${HOME}/.zshrc_custom"  # Master config file
LOG_FILE="${HOME}/.dotconf.log"
BACKUP_DIR="${HOME}/.dotconf_backups"
VERSION="2.0"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 改进的日志函数
log() {
    local level="${2:-INFO}"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local message="[$timestamp] [$level] $1"
    
    case "$level" in
        "ERROR") echo -e "${RED}${message}${NC}" | tee -a "$LOG_FILE" ;;
        "WARN")  echo -e "${YELLOW}${message}${NC}" | tee -a "$LOG_FILE" ;;
        "SUCCESS") echo -e "${GREEN}${message}${NC}" | tee -a "$LOG_FILE" ;;
        "INFO")  echo -e "${BLUE}${message}${NC}" | tee -a "$LOG_FILE" ;;
        *)       echo "$message" | tee -a "$LOG_FILE" ;;
    esac
}

# 错误处理函数
error_exit() {
    log "错误: $1" "ERROR"
    exit 1
}

# 检查依赖
check_dependencies() {
    local deps=("git" "tar")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error_exit "缺少依赖: ${missing_deps[*]}"
    fi
}

# 验证Git URL
validate_git_url() {
    local url="$1"
    if [[ ! "$url" =~ ^(https?://|git@|ssh://) ]]; then
        error_exit "无效的Git URL: $url"
    fi
}

# 检查dotf命令是否可用
check_dotf_command() {
    if ! command -v dotf >/dev/null 2>&1 && [ ! -d "$DOTFILES_REPO" ]; then
        error_exit "'dotf' 命令不可用且dotfiles仓库不存在。请先运行 'init'"
    fi
}

# 创建备份目录
setup_backup_dir() {
    mkdir -p "$BACKUP_DIR" 2>/dev/null || error_exit "无法创建备份目录: $BACKUP_DIR"
}



# 清理旧备份
cleanup_old_backups() {
    local max_backups=10
    local backup_count=$(find "$BACKUP_DIR" -name "dotconf_*.tar.gz" | wc -l)
    
    if [ "$backup_count" -gt "$max_backups" ]; then
        log "清理旧备份文件..." "INFO"
        find "$BACKUP_DIR" -name "dotconf_*.tar.gz" -type f -printf '%T@ %p\n' | \
        sort -n | head -n $((backup_count - max_backups)) | \
        cut -d' ' -f2- | xargs rm -f
    fi
}

init_repo() {
    log "开始初始化dotfiles仓库..." "INFO"
    
    if [ -d "${DOTFILES_REPO}" ]; then
        log "⚠️ Dotfiles仓库已存在于 ${DOTFILES_REPO}" "WARN"
        return 1
    fi

    # 检查依赖
    check_dependencies

    # 创建bare仓库
    if ! git init --bare "$DOTFILES_REPO" >/dev/null 2>&1; then
        error_exit "初始化Git仓库失败"
    fi

    # 创建dotf别名
    local alias_cmd="alias dotf='/usr/bin/git --git-dir=${DOTFILES_REPO} --work-tree=\$HOME'"
    
    # 更新shell配置文件
    local profiles=(.bashrc .zshrc .bash_profile .zprofile .profile)
    local updated_profiles=0
    
    for profile in "${profiles[@]}"; do
        if [ -f "${HOME}/${profile}" ]; then
            if ! grep -q "alias dotf=" "${HOME}/${profile}"; then
                echo "$alias_cmd" >> "${HOME}/${profile}"
                log "➕ 已添加别名到 ${profile}" "SUCCESS"
                ((updated_profiles++))
            fi
        fi
    done
    
    if [ "$updated_profiles" -eq 0 ]; then
        log "⚠️ 未找到可更新的shell配置文件" "WARN"
    fi

    # 重新加载shell配置
    if [ -f "${HOME}/.zshrc" ]; then
        source "${HOME}/.zshrc" 2>/dev/null || true
    elif [ -f "${HOME}/.bashrc" ]; then
        source "${HOME}/.bashrc" 2>/dev/null || true
    fi

    # 初始化跟踪
    if command -v dotf >/dev/null 2>&1; then
        dotf config --local status.showUntrackedFiles no || true
        log "已设置 status.showUntrackedFiles no，dotf status 只显示已跟踪文件" "INFO"
        
        # 添加常见配置文件
        local config_files=(.zshrc .zprofile .zshrc_custom .bashrc .bash_profile .vimrc .gitconfig)
        for file in "${config_files[@]}"; do
            if [ -f "${HOME}/${file}" ]; then
                dotf add "$file" 2>/dev/null || true
            fi
        done
        
        # 创建主配置文件
        echo "# Dotfiles Configuration - $(date)" > "${CONFIG_PROFILE}"
        dotf add "${CONFIG_PROFILE}" 2>/dev/null || true
        
        if dotf commit -m "🎉 初始提交 - $(date)" >/dev/null 2>&1; then
            log "✅ 初始提交成功" "SUCCESS"
        else
            log "⚠️ 初始提交失败（可能没有文件需要提交）" "WARN"
        fi
    else
        log "⚠️ dotf命令不可用，请重新加载shell" "WARN"
    fi
    
    log "✅ Dotfiles仓库已初始化: ${DOTFILES_REPO}" "SUCCESS"
    log "💡 开始添加文件: dotf add <file>" "INFO"
}

sync_changes() {
    log "开始同步配置更改..." "INFO"
    
    check_dotf_command
    
    # 检查是否有更改
    if ! dotf status --porcelain | grep -q .; then
        log "ℹ️ 没有需要同步的更改" "INFO"
        return 0
    fi

    # 提交所有更改的文件
    dotf add -u 2>/dev/null || true
    
    local commit_msg="🔄 自动同步: $(date +'%Y-%m-%d %H:%M:%S')"
    if dotf commit -m "$commit_msg" >/dev/null 2>&1; then
        log "✅ 更改已提交" "SUCCESS"
    else
        log "⚠️ 提交失败（可能没有更改）" "WARN"
        return 0
    fi
    
    # 推送到远程仓库
    if dotf remote -v | grep -q 'origin'; then
        if dotf push origin main >/dev/null 2>&1; then
            log "🚀 配置已同步到远程仓库" "SUCCESS"
        else
            log "⚠️ 推送到远程仓库失败" "WARN"
        fi
    else
        log "ℹ️ 未配置远程仓库。使用: dotf remote add origin <URL>" "INFO"
    fi
    
    # 创建备份快照
    setup_backup_dir
    local backup_name="${BACKUP_DIR}/dotconf_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    if tar -czf "$backup_name" -C "$HOME" .zshrc .zshrc_custom .bashrc .bash_profile .gitconfig .vimrc >/dev/null 2>&1; then
        log "💾 本地备份已创建: ${backup_name}" "SUCCESS"
        cleanup_old_backups
    else
        log "⚠️ 备份创建失败" "WARN"
    fi
}

migrate_config() {
    local repo_url="$1"
    
    if [ -z "$repo_url" ]; then
        error_exit "缺少Git URL参数"
    fi
    
    validate_git_url "$repo_url"
    log "开始迁移配置: $repo_url" "INFO"
    
    # 检查依赖
    check_dependencies
    
    # 安装必要的包
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew >/dev/null 2>&1; then
            brew install git tree >/dev/null 2>&1 || log "⚠️ 包安装可能失败" "WARN"
        else
            log "⚠️ Homebrew未安装" "WARN"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update >/dev/null 2>&1 || log "⚠️ apt更新失败" "WARN"
            sudo apt-get install -y git tree >/dev/null 2>&1 || log "⚠️ 包安装可能失败" "WARN"
        else
            log "⚠️ apt-get不可用" "WARN"
        fi
    fi

    # 创建仓库目录
    if [ -d "$DOTFILES_REPO" ]; then
        log "⚠️ 仓库目录已存在，将备份并重新创建" "WARN"
        mv "$DOTFILES_REPO" "${DOTFILES_REPO}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    mkdir -p "$DOTFILES_REPO" 2>/dev/null || error_exit "无法创建仓库目录"
    
    # 克隆仓库
    if ! git clone --bare "$repo_url" "$DOTFILES_REPO" >/dev/null 2>&1; then
        error_exit "克隆仓库失败: $repo_url"
    fi
    
    # 定义dotf别名
    local alias_cmd="alias dotf='/usr/bin/git --git-dir=${DOTFILES_REPO} --work-tree=\$HOME'"
    
    # 添加到shell配置文件
    if [ -f "${HOME}/.zshrc" ]; then
        echo -e "\n${alias_cmd}" >> "${HOME}/.zshrc"
        log "➕ 已添加别名到 .zshrc" "SUCCESS"
    fi
    
    if [ -f "${HOME}/.bashrc" ]; then
        echo "$alias_cmd" >> "${HOME}/.bashrc"
        log "➕ 已添加别名到 .bashrc" "SUCCESS"
    fi
    
    # 重新加载配置
    source "${HOME}/.zshrc" 2>/dev/null || source "${HOME}/.bashrc" 2>/dev/null || true
    
    # 检出文件
    if ! /usr/bin/git --git-dir="${DOTFILES_REPO}" --work-tree="${HOME}" checkout -f main >/dev/null 2>&1; then
        log "⚠️ 检出文件失败，尝试检出master分支" "WARN"
        /usr/bin/git --git-dir="${DOTFILES_REPO}" --work-tree="${HOME}" checkout -f master >/dev/null 2>&1 || \
        error_exit "检出文件失败"
    fi
    
    /usr/bin/git --git-dir="${DOTFILES_REPO}" --work-tree="${HOME}" config --local status.showUntrackedFiles no || true
    log "已设置 status.showUntrackedFiles no，dotf status 只显示已跟踪文件" "INFO"
    
    # 设置新配置文件
    if [ ! -f "${CONFIG_PROFILE}" ]; then
        echo "# 新系统配置文件 - $(date)" > "${CONFIG_PROFILE}"
        log "➕ 已创建新配置文件" "SUCCESS"
    fi
    
    log "✅ 配置迁移成功!" "SUCCESS"
    log "   启动zsh: zsh" "INFO"
    log "   编辑配置: nano ${CONFIG_PROFILE}" "INFO"
}

create_backup() {
    log "创建配置备份..." "INFO"
    
    setup_backup_dir
    local backup_name="${BACKUP_DIR}/dotconf_manual_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # 备份常见配置文件
    local config_files=(.zshrc .zshrc_custom .bashrc .bash_profile .gitconfig .vimrc)
    local files_to_backup=()
    
    for file in "${config_files[@]}"; do
        if [ -f "${HOME}/${file}" ]; then
            files_to_backup+=("$file")
        fi
    done
    
    if [ ${#files_to_backup[@]} -eq 0 ]; then
        log "⚠️ 没有找到配置文件需要备份" "WARN"
        return 1
    fi
    
    if tar -czf "$backup_name" -C "$HOME" "${files_to_backup[@]}" >/dev/null 2>&1; then
        log "💾 手动备份已创建: ${backup_name}" "SUCCESS"
        log "   备份文件: ${files_to_backup[*]}" "INFO"
        cleanup_old_backups
    else
        error_exit "备份创建失败"
    fi
}

clean_backups() {
    log "清理旧备份文件..." "INFO"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        log "ℹ️ 备份目录不存在" "INFO"
        return 0
    fi
    
    local backup_count=$(find "$BACKUP_DIR" -name "dotconf_*.tar.gz" | wc -l)
    log "发现 $backup_count 个备份文件" "INFO"
    
    if [ "$backup_count" -gt 0 ]; then
        find "$BACKUP_DIR" -name "dotconf_*.tar.gz" -type f -delete
        log "✅ 已清理所有备份文件" "SUCCESS"
    fi
}

show_status() {
    log "显示当前状态..." "INFO"
    
    echo -e "\n${BLUE}=== Dotconf 状态报告 ===${NC}"
    echo -e "版本: $VERSION"
    echo -e "仓库路径: $DOTFILES_REPO"
    echo -e "配置文件: $CONFIG_PROFILE"
    echo -e "日志文件: $LOG_FILE"
    echo -e "备份目录: $BACKUP_DIR"
    
    # 检查仓库状态
    if [ -d "$DOTFILES_REPO" ]; then
        echo -e "\n${GREEN}✅ Dotfiles仓库存在${NC}"
        if command -v dotf >/dev/null 2>&1; then
            echo -e "${GREEN}✅ dotf命令可用${NC}"
            
            # 显示远程仓库
            if dotf remote -v | grep -q 'origin'; then
                echo -e "${GREEN}✅ 远程仓库已配置${NC}"
                dotf remote -v | grep origin
            else
                echo -e "${YELLOW}⚠️ 未配置远程仓库${NC}"
            fi
            
            # 显示状态
            local status_output=$(dotf status --porcelain 2>/dev/null || echo "")
            if [ -n "$status_output" ]; then
                echo -e "\n${YELLOW}📝 待提交的更改:${NC}"
                echo "$status_output"
            else
                echo -e "\n${GREEN}✅ 工作目录干净${NC}"
            fi
        else
            echo -e "\n${YELLOW}⚠️ dotf命令不可用${NC}"
        fi
    else
        echo -e "\n${RED}❌ Dotfiles仓库不存在${NC}"
    fi
    
    # 显示备份状态
    if [ -d "$BACKUP_DIR" ]; then
        local backup_count=$(find "$BACKUP_DIR" -name "dotconf_*.tar.gz" | wc -l)
        echo -e "\n${BLUE}📦 备份文件: $backup_count 个${NC}"
        if [ "$backup_count" -gt 0 ]; then
            find "$BACKUP_DIR" -name "dotconf_*.tar.gz" -type f -printf '%T@ %p\n' | \
            sort -n | tail -5 | cut -d' ' -f2- | while read -r file; do
                echo "   $(basename "$file")"
            done
        fi
    else
        echo -e "\n${YELLOW}⚠️ 备份目录不存在${NC}"
    fi
    
    echo -e "\n${BLUE}=== 结束 ===${NC}\n"
}

show_help() {
    echo -e "${BLUE}Terminal Configuration Manager v$VERSION${NC}\n"
    echo "命令:"
    echo "  init     设置dotfiles仓库"
    echo "  sync     提交并推送配置更改"
    echo "  migrate  克隆配置到新机器"
    echo "  backup   创建手动备份"
    echo "  clean    清理旧备份文件"
    echo "  status   显示当前状态"
    echo "  help     显示此帮助信息"
    echo ""
    echo "使用示例:"
    echo "1. $0 init           # 首次设置"
    echo "2. dotf add ~/.config/file # 添加新配置"
    echo "3. $0 sync           # 推送更改"
    echo "4. $0 migrate <URL>  # 在新机器上"
    echo "5. $0 status         # 查看状态"
    echo ""
    echo "环境变量:"
    echo "  DOTFILES_DIR    自定义dotfiles仓库路径"
    echo ""
}

# 主命令路由器
main() {
    # 检查参数
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    case "$1" in
        init)
            init_repo
            ;;
        sync)
            sync_changes
            ;;
        migrate)
            if [ -z "${2:-}" ]; then
                error_exit "缺少Git URL。用法: $0 migrate <git-repo-url>"
            fi
            migrate_config "$2"
            ;;
        backup)
            create_backup
            ;;
        clean)
            clean_backups
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log "未知命令: $1" "ERROR"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 