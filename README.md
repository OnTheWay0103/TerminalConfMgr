# TerminalConfigMgr

一个安全、可靠的终端配置文件管理系统。

## 🚀 快速开始

### 1. 首次安装
```bash
# 克隆仓库
git clone https://github.com/yourusername/TerminalConfigMgr.git ~/.dotfiles
cd ~/.dotfiles

# 安全部署配置
./tools/core.sh check   # 系统检查
./tools/core.sh deploy  # 部署配置
```

### 2. 日常使用
```bash
# 查看帮助
./tools/core.sh help

# 恢复原始配置
./tools/core.sh restore
```

## 📁 项目结构

```
TerminalConfigMgr/
├── configs/              # 配置文件
│   ├── .zshrc           # Zsh配置
│   ├── .bashrc          # Bash配置
│   ├── .vimrc           # Vim配置
│   ├── .gitconfig       # Git配置
│   └── .gitignore_global # 全局忽略规则
├── tools/               # 工具脚本
│   ├── core.sh          # 核心功能（部署/恢复）
│   ├── security_check.sh # 安全检查
│   ├── safe_deploy.sh   # 安全部署
│   └── enhanced_backup.sh # 增强备份
├── templates/           # 配置模板
└── docs/               # 文档
```

## 🔧 核心功能

### 安全部署
- ✅ 自动备份现有配置
- ✅ 安全检查
- ✅ 系统兼容性验证
- ✅ 一键恢复

### 备份系统
- ✅ 完整系统快照
- ✅ 智能恢复
- ✅ 差异备份
- ✅ 自动清理

### 跨平台支持
- ✅ macOS
- ✅ Linux
- ✅ WSL

## 📋 使用指南

### 添加新配置
1. 将配置文件放入 `configs/` 目录
2. 运行 `./tools/core.sh deploy`

### 备份管理
```bash
# 创建系统快照
./tools/enhanced_backup.sh snapshot

# 列出备份
./tools/enhanced_backup.sh list

# 恢复到指定快照
./tools/enhanced_backup.sh restore snapshot_YYYYMMDD_HHMMSS
```

### 安全检查
```bash
./tools/security_check.sh
```

## 🛡️ 安全特性

- **敏感数据检测**：自动扫描API密钥和密码
- **文件权限验证**：确保配置文件安全权限
- **备份验证**：完整性检查
- **系统快照**：部署前自动创建恢复点

## 🆘 故障排除

### 恢复误操作
```bash
# 查看可用备份
./tools/enhanced_backup.sh list

# 紧急回滚
./tools/enhanced_backup.sh rollback
```

### 系统检查失败
```bash
# 重新检查系统
./tools/core.sh check
```

## 📚 文档

- [兼容性指南](docs/COMPATIBILITY.md)
- [远程同步](docs/REMOTE_SYNC.md)
- [仓库设计](docs/REPOSITORY_DESIGN.md)

## 🎯 最佳实践

1. **定期备份**：每周运行一次快照
2. **测试环境**：先在测试环境验证配置
3. **版本控制**：使用Git管理配置变更
4. **环境分离**：工作/个人配置分离

## 🔍 调试

所有操作日志保存在：`~/.dotconf.log`

## 🤝 贡献

欢迎提交Issue和Pull Request！