# Terminal Configuration Manager (dotconfEx)

一个简单易用的跨平台终端配置文件管理工具，基于 Git bare repository 实现，支持配置文件的版本控制、同步和备份。

## 🚀 特性

- **跨平台支持**: 支持 macOS 和 Linux 系统
- **Git 版本控制**: 使用 Git bare repository 管理配置文件
- **自动备份**: 支持本地备份和远程同步
- **简单易用**: 提供简洁的命令行接口
- **日志记录**: 详细的操作日志和错误处理
- **智能清理**: 自动清理旧备份文件

## 📋 系统要求

- Git
- tar
- bash shell
- 支持的系统: macOS, Linux

## 🛠️ 安装

1. 下载脚本到本地：

```bash
curl -o dotconfEx.sh https://raw.githubusercontent.com/your-repo/dotconfEx.sh
```

2. 添加执行权限：

```bash
chmod +x dotconfEx.sh
```

3. 移动到系统 PATH 中（可选）：

```bash
sudo mv dotconfEx.sh /usr/local/bin/dotconf
```

## 📖 使用方法

### 基本命令

```bash
./dotconfEx.sh <command> [options]
```

### 命令列表

| 命令      | 描述                 | 用法                               |
| --------- | -------------------- | ---------------------------------- |
| `init`    | 初始化 dotfiles 仓库 | `./dotconfEx.sh init`              |
| `sync`    | 同步配置更改到远程   | `./dotconfEx.sh sync`              |
| `migrate` | 在新机器上设置配置   | `./dotconfEx.sh migrate <git-url>` |
| `backup`  | 创建手动备份         | `./dotconfEx.sh backup`            |
| `clean`   | 清理旧备份文件       | `./dotconfEx.sh clean`             |
| `status`  | 显示当前状态         | `./dotconfEx.sh status`            |
| `help`    | 显示帮助信息         | `./dotconfEx.sh help`              |

## 🎯 快速开始

### 1. 首次设置

```bash
# 初始化dotfiles仓库
./dotconfEx.sh init
```

这将：

- 创建 Git bare repository (`~/.dotfiles`)
- 设置 `dotf` 别名
- 自动添加到 shell 配置文件
- 初始化跟踪常见配置文件

### 2. 添加配置文件

```bash
# 添加新的配置文件
dotf add ~/.config/nvim/init.vim
dotf add ~/.tmux.conf

# 提交更改
dotf commit -m "添加nvim和tmux配置"
```

### 3. 同步到远程仓库

```bash
# 添加远程仓库
dotf remote add origin https://github.com/username/dotfiles.git

# 同步更改
./dotconfEx.sh sync
```

### 4. 在新机器上迁移配置

```bash
# 克隆配置到新机器
./dotconfEx.sh migrate https://github.com/username/dotfiles.git
```

## 📁 文件结构

```
~/
├── .dotfiles/              # Git bare repository
├── .zshrc_custom          # 主配置文件
├── .dotconf.log           # 日志文件
└── .dotconf_backups/      # 备份目录
    ├── dotconf_20231201_143022.tar.gz
    └── dotconf_manual_20231201_150000.tar.gz
```

## 🔧 配置说明

### 环境变量

- `DOTFILES_DIR`: 自定义 dotfiles 仓库路径（默认: `~/.dotfiles`）

### 自动跟踪的配置文件

工具会自动跟踪以下配置文件：

- `.zshrc`
- `.zshrc_custom`
- `.bashrc`
- `.bash_profile`
- `.vimrc`
- `.gitconfig`

### .gitignore 文件

本项目包含两个 `.gitignore` 文件，服务于不同的目的：

#### 1. 项目仓库 .gitignore

- **位置**: `TerminalConfigMgr/.gitignore`
- **作用**: 管理 dotconfEx.sh 工具本身的代码仓库
- **忽略内容**: 工具的日志文件、临时文件、IDE 配置等

#### 2. 用户目录 .gitignore

- **位置**: `~/.gitignore`（用户主目录）
- **作用**: 管理用户的 dotfiles 仓库
- **忽略内容**: 由用户自定义，通常包括系统文件、临时文件、缓存文件等

**注意**: 用户目录的 `.gitignore` 文件需要用户自己创建和管理，作为 dotfiles 的一部分。工具不会自动创建此文件。

## 📝 使用示例

### 完整工作流程

```bash
# 1. 初始化
./dotconfEx.sh init

# 2. 添加配置文件
dotf add ~/.config/alacritty/alacritty.yml
dotf add ~/.config/starship.toml

# 3. 提交更改
dotf commit -m "添加终端和提示符配置"

# 4. 设置远程仓库
dotf remote add origin https://github.com/username/dotfiles.git

# 5. 同步到远程
./dotconfEx.sh sync

# 6. 查看状态
./dotconfEx.sh status
```

### 备份和恢复

```bash
# 创建手动备份
./dotconfEx.sh backup

# 清理旧备份
./dotconfEx.sh clean

# 查看备份状态
ls -la ~/.dotconf_backups/
```

## ⚠️ 注意事项

1. **首次使用**: 运行 `init` 命令后需要重新加载 shell 或重启终端
2. **远程仓库**: 建议设置远程仓库以便在多台机器间同步
3. **备份策略**: 工具会自动保留最近 10 个备份文件
4. **权限问题**: 确保对相关目录有读写权限
5. **冲突处理**: 在迁移配置时，现有文件会被覆盖

## 🐛 故障排除

### 常见问题

1. **dotf 命令不可用**

   ```bash
   # 重新加载shell配置
   source ~/.zshrc
   # 或重启终端
   ```

2. **权限错误**

   ```bash
   # 检查目录权限
   ls -la ~/.dotfiles/
   # 修复权限
   chmod 755 ~/.dotfiles/
   ```

3. **Git 配置问题**
   ```bash
   # 检查Git配置
   dotf config --list
   # 设置用户信息
   dotf config user.name "Your Name"
   dotf config user.email "your.email@example.com"
   ```

## 📄 许可证

本项目采用 MIT 许可证。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 支持

如果遇到问题，请：

1. 查看日志文件: `~/.dotconf.log`
2. 运行状态检查: `./dotconfEx.sh status`
3. 提交 Issue 到项目仓库

---

**版本**: 2.0  
**最后更新**: 2024 年 12 月
