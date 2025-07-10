# Dotf 兼容性说明

## 概述

Dotf 已优化以支持多种 shell 环境，特别是针对 macOS 系统从 bash 迁移到 zsh 的情况。

## 兼容性改进

### 1. Shell 环境检测

**问题**: 苹果系统从 macOS Catalina 开始默认使用 zsh，但脚本可能仍在使用 bash 特定语法。

**解决方案**:

- 添加了 `detect_shell()` 函数自动检测当前 shell
- 支持 bash 和 zsh 环境变量检测
- 智能选择正确的配置文件路径

```bash
# 自动检测 shell 类型
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}
```

### 2. 脚本路径获取

**问题**: `BASH_SOURCE[0]` 在 zsh 中不可用。

**解决方案**:

- 兼容性路径获取函数
- 支持 bash 和 zsh 的不同语法
- 提供回退方案

```bash
get_script_dir() {
    local source=""

    # bash 环境
    if [ -n "${BASH_SOURCE[0]}" ]; then
        source="${BASH_SOURCE[0]}"
    # zsh 环境
    elif [ -n "${(%):-%x}" ]; then
        source="${(%):-%x}"
    else
        source="$0"
    fi

    # 处理符号链接
    while [ -L "$source" ]; do
        dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done

    echo "$(cd -P "$(dirname "$source")" && pwd)"
}
```

### 3. Shell 配置文件管理

**问题**: 不同 shell 使用不同的配置文件。

**解决方案**:

- 自动检测 shell 类型
- 智能选择配置文件
- 避免重复添加 PATH

```bash
get_shell_config() {
    local shell_type="$1"

    case "$shell_type" in
        "zsh")
            if [ -f "$HOME/.zshrc" ]; then
                echo "$HOME/.zshrc"
            elif [ -f "$HOME/.zprofile" ]; then
                echo "$HOME/.zprofile"
            fi
            ;;
        "bash")
            if [ -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                echo "$HOME/.bash_profile"
            fi
            ;;
    esac
}
```

## 测试结果

### 环境信息

- **操作系统**: macOS (Darwin)
- **架构**: arm64
- **默认 Shell**: zsh 5.9
- **兼容 Shell**: bash 3.2.57

### 测试覆盖

- ✅ bash 语法检查
- ✅ zsh 语法检查
- ✅ shell 检测功能
- ✅ 路径获取功能
- ✅ 配置文件管理
- ✅ 依赖检查
- ✅ 权限处理

## 使用建议

### macOS 用户

1. **推荐使用 zsh**: 苹果官方推荐，更好的功能支持
2. **自动检测**: 脚本会自动检测并适配当前 shell
3. **配置文件**: 自动选择正确的配置文件 (.zshrc 或 .bashrc)

### Linux 用户

1. **bash 兼容**: 大多数 Linux 发行版默认使用 bash
2. **zsh 可选**: 如果安装了 zsh，脚本也能正常工作

### Windows 用户 (WSL)

1. **WSL 支持**: 在 WSL 环境中完全兼容
2. **配置文件**: 自动处理 WSL 特定的配置文件

## 故障排除

### 常见问题

**Q: 脚本在 zsh 中报错 "BASH_SOURCE: unbound variable"**
A: 已修复，现在使用兼容性检测

**Q: PATH 没有正确添加到配置文件**
A: 脚本现在会检查是否已存在，避免重复添加

**Q: 权限问题导致安装失败**
A: 自动降级到用户目录 (~/.local/bin)

### 手动修复

如果遇到问题，可以手动执行：

```bash
# 检测当前 shell
echo $SHELL

# 手动添加 PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# 重新加载配置
source ~/.zshrc
```

## 版本历史

### v2.3 (当前版本)

- ✅ 添加 shell 环境检测
- ✅ 兼容 bash 和 zsh 路径获取
- ✅ 智能配置文件管理
- ✅ 改进错误处理
- ✅ 添加兼容性测试

### v2.2

- 基础功能实现
- 单仓库设计

### v2.1

- 初始版本
- 基本配置管理

## 贡献

欢迎提交兼容性相关的改进建议和测试报告！
