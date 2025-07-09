# 远程仓库同步指南

## 概述

DotconfEx 支持将配置文件同步到远程 Git 仓库（如 GitHub、GitLab 等），实现多设备间的配置同步。

## 快速开始

### 1. 初始化并配置远程仓库

```bash
# 初始化本地仓库
dotconf init

# 在初始化过程中，会提示输入远程仓库 URL
# 例如: https://github.com/yourusername/dotfiles.git
```

### 2. 手动配置远程仓库

如果初始化时没有配置远程仓库，可以手动添加：

```bash
# 进入 dotfiles 目录
cd ~/.dotfiles

# 添加远程仓库
git remote add origin https://github.com/yourusername/dotfiles.git

# 推送到远程
git push -u origin main
```

### 3. 同步更改

```bash
# 自动同步（拉取 + 推送）
dotconf sync

# 或者手动操作
cd ~/.dotfiles
git add .
git commit -m "更新配置"
git push origin main
```

## 详细步骤

### 步骤 1: 创建远程仓库

#### GitHub 方式

1. 访问 [GitHub](https://github.com)
2. 点击 "New repository"
3. 仓库名建议：`dotfiles`
4. 选择 "Private"（推荐，因为包含个人配置）
5. 不要初始化 README（我们会从本地推送）

#### GitLab 方式

1. 访问 [GitLab](https://gitlab.com)
2. 点击 "New project"
3. 项目名：`dotfiles`
4. 选择可见性级别
5. 创建项目

### 步骤 2: 配置本地仓库

```bash
# 方法 1: 使用 dotconf init（推荐）
dotconf init

# 方法 2: 手动配置
cd ~/.dotfiles
git remote add origin https://github.com/yourusername/dotfiles.git
git branch -M main
git push -u origin main
```

### 步骤 3: 添加配置文件

```bash
# 添加单个文件
dotconf add .zshrc

# 添加目录
dotconf add .config/nvim/

# 查看状态
dotconf status
```

### 步骤 4: 同步到远程

```bash
# 自动同步（推荐）
dotconf sync

# 手动同步
cd ~/.dotfiles
git add .
git commit -m "更新配置"
git push origin main
```

## 在新设备上使用

### 方法 1: 使用 migrate 命令

```bash
# 克隆远程仓库到本地
dotconf migrate https://github.com/yourusername/dotfiles.git
```

### 方法 2: 手动克隆

```bash
# 克隆仓库
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles

# 创建符号链接
cd ~/.dotfiles
./dotconfEx.sh init
```

## 高级功能

### 1. 分支管理

```bash
cd ~/.dotfiles

# 创建功能分支
git checkout -b feature/new-config

# 开发完成后合并
git checkout main
git merge feature/new-config
git push origin main
```

### 2. 标签管理

```bash
cd ~/.dotfiles

# 创建版本标签
git tag -a v1.0.0 -m "第一个稳定版本"
git push origin v1.0.0
```

### 3. 自动同步脚本

创建 `~/.zshrc` 或 `~/.bashrc` 中的别名：

```bash
# 添加到 shell 配置文件
alias dotsync='dotconf sync'
alias dotstatus='dotconf status'
alias dotadd='dotconf add'
```

## 常见问题

### Q: 推送失败 "Permission denied"

A: 检查 SSH 密钥配置或使用 HTTPS 方式

```bash
# 使用 HTTPS（推荐新手）
git remote set-url origin https://github.com/yourusername/dotfiles.git

# 或配置 SSH 密钥
ssh-keygen -t ed25519 -C "your-email@example.com"
# 然后添加到 GitHub SSH keys
```

### Q: 合并冲突怎么办？

A: 手动解决冲突

```bash
cd ~/.dotfiles
git status  # 查看冲突文件
# 编辑冲突文件，解决冲突
git add .
git commit -m "解决冲突"
git push origin main
```

### Q: 如何备份远程仓库？

A: 定期备份或使用镜像

```bash
# 创建备份
git clone --mirror https://github.com/yourusername/dotfiles.git dotfiles-backup

# 或使用 GitHub 的备份功能
```

## 最佳实践

### 1. 安全性

- 使用私有仓库存储敏感配置
- 避免提交包含密码的文件
- 使用 `.gitignore` 排除敏感信息

### 2. 组织性

- 使用有意义的提交信息
- 定期清理不需要的配置
- 保持仓库结构清晰

### 3. 自动化

- 设置定时同步
- 使用 Git hooks 自动检查
- 配置 CI/CD 进行测试

### 4. 版本控制

- 使用语义化版本号
- 为重要更改创建标签
- 保持提交历史清晰

## 示例工作流

### 日常使用流程

```bash
# 1. 检查状态
dotconf status

# 2. 添加新配置
dotconf add .config/alacritty/alacritty.yml

# 3. 同步到远程
dotconf sync

# 4. 验证同步
dotconf status
```

### 新设备设置流程

```bash
# 1. 安装 dotconf
curl -fsSL https://raw.githubusercontent.com/yourusername/dotconf/main/install.sh | bash

# 2. 迁移配置
dotconf migrate https://github.com/yourusername/dotfiles.git

# 3. 验证安装
dotconf status
```

## 故障排除

### 检查网络连接

```bash
# 测试 GitHub 连接
ping github.com

# 测试 SSH 连接
ssh -T git@github.com
```

### 检查 Git 配置

```bash
# 查看远程仓库
git remote -v

# 查看 Git 配置
git config --list
```

### 重置远程仓库

```bash
# 如果需要重新配置
git remote remove origin
git remote add origin https://github.com/yourusername/dotfiles.git
git push -u origin main
```

## 总结

通过以上步骤，你可以轻松地将配置文件同步到远程仓库，实现多设备间的配置一致性。记住：

1. **安全性第一** - 使用私有仓库
2. **定期同步** - 保持配置最新
3. **版本管理** - 使用标签管理重要版本
4. **自动化** - 减少手动操作

开始享受跨设备的配置同步体验吧！
