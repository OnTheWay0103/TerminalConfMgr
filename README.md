# Terminal Configuration Manager (dotconfEx)

一个简单易用的跨平台配置文件同步工具，采用**单仓库设计**，帮助您在多台电脑间保持配置文件一致。参考了 [Mathias Bynens dotfiles](https://github.com/mathiasbynens/dotfiles) 的设计理念。

## 🎯 设计理念

**单仓库设计** - 只需要一个 Git 仓库管理所有配置文件，通过符号链接自动管理，大大简化了使用复杂度。

## 功能特点

- 🚀 **单仓库管理**: 只需要一个仓库，简化使用
- 🔗 **自动符号链接**: 自动创建和管理符号链接
- 🔄 **智能同步**: 支持本地到远程的自动同步
- 🛡️ **冲突处理**: 智能处理多设备间的配置冲突
- 📦 **备份恢复**: 自动备份和恢复功能
- 🎨 **配置模板**: 提供常用配置文件模板
- 🌐 **跨平台**: 支持 macOS 和 Linux

## 快速开始

### 1. 一键安装

```bash
# 下载并运行安装脚本
curl -fsSL https://raw.githubusercontent.com/your-repo/dotconfEx.sh/main/install.sh | bash
```

或者手动安装：

```bash
# 下载脚本
curl -o dotconfEx.sh https://raw.githubusercontent.com/your-repo/dotconfEx.sh/main/dotconfEx.sh
chmod +x dotconfEx.sh

# 运行安装
./install.sh
```

### 2. 首次设置

```bash
dotconf init
```

脚本会引导您：

- 创建本地 dotfiles 仓库
- 配置远程仓库（可选）
- 创建基础配置文件
- 自动创建符号链接

### 3. 在新机器上同步

```bash
dotconf migrate <your-repo-url>
```

## 常用命令

| 命令            | 说明                   |
| --------------- | ---------------------- |
| `init`          | 初始化 dotfiles 仓库   |
| `sync`          | 同步配置更改到远程仓库 |
| `migrate <URL>` | 在新机器上克隆配置     |
| `add <file>`    | 添加文件到跟踪         |
| `remove <file>` | 从跟踪中移除文件       |
| `status`        | 显示当前状态           |

## 使用场景

### 场景 1: 首次设置

```bash
# 1. 初始化仓库
dotconf init

# 2. 添加更多配置文件
dotconf add .config/nvim/init.vim
dotconf add .tmux.conf

# 3. 同步到远程
dotconf sync
```

### 场景 2: 新机器配置

```bash
# 1. 克隆配置
dotconf migrate https://github.com/username/dotfiles.git

# 2. 检查状态
dotconf status
```

### 场景 3: 日常使用

```bash
# 1. 修改配置文件后同步
dotconf sync

# 2. 添加新配置
dotconf add .config/alacritty/alacritty.yml
dotconf sync
```

## 工作原理

### 单仓库设计

```
~/.dotfiles/           # Git 仓库
├── .zshrc            # 配置文件
├── .gitconfig        # Git 配置
├── .vimrc            # Vim 配置
└── .config/          # 配置目录
    └── nvim/
        └── init.vim

~/.zshrc -> ~/.dotfiles/.zshrc        # 符号链接
~/.gitconfig -> ~/.dotfiles/.gitconfig # 符号链接
~/.vimrc -> ~/.dotfiles/.vimrc        # 符号链接
```

### 优势

1. **简单直观**: 只需要一个仓库管理所有配置
2. **自动管理**: 符号链接自动创建和维护
3. **版本控制**: 所有配置都在 Git 版本控制下
4. **易于同步**: 简单的 push/pull 操作
5. **冲突处理**: 自动检测和处理冲突

## 支持的配置文件

- Shell 配置: `.zshrc`, `.bashrc`, `.bash_profile`
- 编辑器配置: `.vimrc`, `.config/nvim/init.vim`
- 终端配置: `.tmux.conf`, `.config/alacritty/`
- Git 配置: `.gitconfig`
- 其他: `.ssh/config`, `.config/` 目录下的配置

## 环境变量

- `DOTFILES_DIR`: 自定义 dotfiles 仓库路径（默认: `~/.dotfiles`）

## 故障排除

### 问题 1: 符号链接问题

```bash
# 检查符号链接
ls -la ~/.zshrc

# 重新创建符号链接
dotconf init
```

### 问题 2: 同步冲突

```bash
# 1. 查看冲突状态
cd ~/.dotfiles
git status

# 2. 手动解决冲突后
git add .
git commit -m "解决冲突"
dotconf sync
```

### 问题 3: 远程仓库连接失败

```bash
# 检查远程仓库配置
cd ~/.dotfiles
git remote -v

# 重新配置远程仓库
git remote remove origin
git remote add origin <your-repo-url>
```

## 与 Mathias Bynens dotfiles 的对比

| 特性     | Mathias dotfiles | dotconfEx (单仓库)    |
| -------- | ---------------- | --------------------- |
| 安装方式 | bootstrap.sh     | install.sh + 一键安装 |
| 文件组织 | 直接管理         | 单仓库 + 符号链接     |
| 同步机制 | 手动更新         | 自动同步              |
| 复杂度   | 中等             | 简单                  |
| 学习曲线 | 较陡             | 平缓                  |

## 设计优势

### 跨平台兼容性

| 特性       | 支持情况                    | 说明           |
| ---------- | --------------------------- | -------------- |
| Shell 环境 | bash, zsh                   | 自动检测并适配 |
| 操作系统   | macOS, Linux, Windows (WSL) | 跨平台兼容     |
| 配置文件   | 自动检测 .zshrc/.bashrc     | 智能配置 PATH  |
| 权限处理   | 自动降级到用户目录          | 避免权限问题   |

### 相比 Bare Git 仓库方案

| 方面       | Bare Git 仓库        | 单仓库设计 |
| ---------- | -------------------- | ---------- |
| 仓库数量   | 2 个 (bare + remote) | 1 个       |
| 配置复杂度 | 高                   | 低         |
| 学习成本   | 高                   | 低         |
| 维护难度   | 高                   | 低         |
| 直观性     | 低                   | 高         |

### 相比传统方案

- ✅ **简单**: 只需要一个仓库
- ✅ **直观**: 文件组织清晰
- ✅ **自动**: 符号链接自动管理
- ✅ **安全**: 自动备份原文件
- ✅ **灵活**: 支持任意配置文件

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License
