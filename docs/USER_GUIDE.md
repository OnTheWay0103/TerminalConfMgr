# TerminalConfigMgr 用户指南

## 📋 快速开始

### 1. 首次安装
```bash
# 克隆仓库
git clone https://github.com/yourusername/TerminalConfigMgr.git ~/.dotfiles
cd ~/.dotfiles

# 系统检查
./tools/security_check.sh

# 安全部署
./tools/safe_deploy.sh --dry-run  # 预览
./tools/safe_deploy.sh            # 实际部署
```

### 2. 基本使用
```bash
./tools/core.sh help      # 查看帮助
./tools/core.sh check     # 系统检查
./tools/core.sh deploy    # 部署配置
./tools/core.sh restore   # 恢复配置
```

## 🔧 兼容性说明

### 支持平台
- **macOS** ✅ 完全支持 (zsh默认)
- **Linux** ✅ 完全支持 (bash/zsh)
- **WSL** ✅ 完全支持

### Shell支持
- **zsh** ✅ 自动检测
- **bash** ✅ 自动检测
- **其他** ⚠️ 可能需手动配置

### 系统要求
```bash
# 必需工具
git ✓
bash ✓  
zsh ✓
```

## 🔄 远程同步

### 设置远程仓库
```bash
# GitHub 示例
cd ~/.dotfiles
git remote add origin https://github.com/yourusername/dotfiles.git
git push -u origin main
```

### 日常使用
```bash
# 添加配置
git add configs/
git commit -m "添加新配置"
git push

# 同步到其他设备
git pull
./tools/core.sh deploy
```

### 新设备迁移
```bash
# 在新设备上
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./tools/safe_deploy.sh
```

## 🛡️ 安全特性

### 自动保护
- **敏感数据检测** - 自动扫描API密钥
- **文件权限验证** - 确保配置文件安全权限
- **完整备份** - 部署前100%备份
- **一键恢复** - 误操作可快速回滚

### 最佳实践
```bash
# 定期备份
./tools/enhanced_backup.sh snapshot

# 检查敏感数据
./tools/security_check.sh

# 清理旧备份
./tools/enhanced_backup.sh cleanup 30
```

## 📁 仓库结构（精简设计）

```
TerminalConfigMgr/          # 单仓库设计
├── configs/               # 配置文件
│   ├── .zshrc
│   ├── .bashrc
│   ├── .vimrc
│   └── .gitconfig
├── tools/                 # 核心工具
│   ├── core.sh           # 部署/恢复
│   ├── security_check.sh # 安全检查
│   ├── safe_deploy.sh    # 安全部署
│   └── enhanced_backup.sh # 备份管理
├── templates/            # 配置模板
└── docs/                # 文档
```

## 🎯 使用场景

### 场景1：新电脑设置
```bash
# 1. 克隆配置
git clone <repo> ~/.dotfiles
cd ~/.dotfiles

# 2. 一键部署
./tools/safe_deploy.sh

# 3. 完成！
```

### 场景2：日常配置更新
```bash
# 1. 修改配置
vim configs/.zshrc

# 2. 测试配置
source ~/.zshrc

# 3. 保存更改
git add configs/
git commit -m "更新zsh配置"
git push
```

### 场景3：设备间同步
```bash
# 在工作电脑
./tools/enhanced_backup.sh snapshot

# 在家电脑
git pull
./tools/core.sh deploy
```

## 🆘 故障排除

### 常见问题

| 问题 | 解决方案 |
|------|----------|
| 部署失败 | `./tools/core.sh check` |
| 配置冲突 | `./tools/enhanced_backup.sh list` |
| 想恢复 | `./tools/enhanced_backup.sh rollback` |
| 权限错误 | `./tools/security_check.sh` |

### 紧急恢复
```bash
# 查看可用备份
./tools/enhanced_backup.sh list

# 恢复最新快照
./tools/enhanced_backup.sh restore

# 完全重置
./tools/core.sh restore
```

## 📝 配置模板

### 基础模板
位于 `templates/` 目录：
- `zshrc.example` - Zsh基础配置
- `bashrc.example` - Bash基础配置  
- `vimrc.example` - Vim基础配置
- `gitconfig.example` - Git基础配置

### 使用模板
```bash
# 复制模板
cp templates/zshrc.example configs/.zshrc

# 自定义编辑
vim configs/.zshrc

# 部署
./tools/core.sh deploy
```

## 🔍 调试技巧

### 日志查看
```bash
# 查看操作日志
tail -f ~/.dotconf.log

# 检查备份
ls ~/.config_backups/

# 验证符号链接
ls -la ~/
```

### 测试环境
```bash
# 使用Docker测试
docker run -it ubuntu bash
curl -fsSL <install-script> | bash
```

## 📊 版本控制建议

### Git工作流程
```bash
# 功能开发
git checkout -b feature/new-config
# 修改配置
git add .
git commit -m "添加新功能"
git push origin feature/new-config

# 合并到主分支
git checkout main
git merge feature/new-config
git push
```

### 标签管理
```bash
# 创建稳定版本标签
git tag -a v1.0.0 -m "稳定版本"
git push origin v1.0.0
```

## 🎉 开始使用

1. **复制本仓库**
2. **自定义配置** (configs/目录)
3. **安全部署** (./tools/safe_deploy.sh)
4. **享受统一管理** ✨

---

**提示**: 所有操作都有完整备份，放心使用！