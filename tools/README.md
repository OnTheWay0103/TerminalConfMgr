# 配置文件管理工具

这个目录包含了用于安全管理配置文件的工具，确保在修改配置文件前自动创建备份。

## 工具说明

### 1. backup_utils.sh - 备份工具

提供文件备份、恢复和管理功能。

#### 主要功能：
- **自动备份**：在修改文件前创建带时间戳的备份
- **版本管理**：自动清理旧备份，保留最新的10个版本
- **备份信息**：在备份文件中添加详细的备份信息
- **恢复功能**：支持从备份文件恢复

#### 使用方法：
```bash
# 备份文件
./tools/backup_utils.sh backup ~/.zshrc_custom "SSH配置修改前备份"

# 列出备份
./tools/backup_utils.sh list .zshrc_custom

# 恢复备份
./tools/backup_utils.sh restore ~/.config_backups/.zshrc_custom.backup.20240712_191100 ~/.zshrc_custom
```

### 2. safe_edit.sh - 安全编辑工具

提供安全的文件编辑功能，在修改前自动备份。

#### 主要功能：
- **安全编辑**：编辑前自动创建备份
- **内容替换**：安全地替换整个文件内容
- **内容追加**：安全地追加内容到文件
- **搜索替换**：安全地执行搜索替换操作

#### 使用方法：
```bash
# 安全编辑文件（手动编辑）
./tools/safe_edit.sh edit ~/.zshrc_custom "SSH配置修改"

# 安全替换文件内容
./tools/safe_edit.sh replace ~/.zshrc_custom "新的配置内容" "配置更新"

# 安全追加内容
./tools/safe_edit.sh append ~/.zshrc_custom "export NEW_VAR=value" "添加环境变量"

# 安全搜索替换
./tools/safe_edit.sh search ~/.zshrc_custom "old_pattern" "new_pattern" "模式替换"
```

## 在代码中使用

### 在脚本中导入备份功能：
```bash
#!/bin/bash
source "$(dirname "$0")/tools/backup_utils.sh"

# 修改文件前自动备份
backup_file "/path/to/config" "修改描述"

# 执行修改操作
# ... 修改代码 ...

echo "✅ 修改完成，备份已创建"
```

### 在Python脚本中使用：
```python
import subprocess
import sys

def safe_edit_file(file_path, description):
    """安全地编辑文件，自动创建备份"""
    try:
        # 创建备份
        result = subprocess.run([
            './tools/backup_utils.sh', 'backup', file_path, description
        ], check=True, capture_output=True, text=True)
        print(result.stdout)
        
        # 执行修改
        # ... 修改代码 ...
        
        print("✅ 文件修改完成")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ 备份失败: {e}")
        return False
```

## 备份目录结构

备份文件存储在 `~/.config_backups/` 目录中：

```
~/.config_backups/
├── .zshrc_custom.backup.20240712_191100
├── .zshrc_custom.backup.20240712_191200
├── .vimrc.backup.20240712_191300
└── ...
```

每个备份文件包含：
- 原始文件内容
- 备份时间戳
- 备份描述
- 原文件路径信息

## 最佳实践

1. **修改前备份**：每次修改配置文件前都使用备份工具
2. **描述性备份**：提供清晰的备份描述，便于后续识别
3. **定期清理**：工具会自动保留最新的10个备份版本
4. **测试恢复**：重要修改前测试备份恢复功能
5. **版本控制**：将备份工具纳入版本控制，确保团队一致性

## 配置选项

可以在 `backup_utils.sh` 中修改以下配置：

```bash
BACKUP_DIR="${HOME}/.config_backups"  # 备份目录
MAX_BACKUPS=10                        # 保留的最大备份数量
```

## 故障排除

### 常见问题：

1. **权限问题**：确保脚本有执行权限 `chmod +x tools/*.sh`
2. **路径问题**：使用绝对路径或确保相对路径正确
3. **macOS兼容性**：已修复macOS特有的命令兼容性问题

### 恢复步骤：

1. 列出可用备份：`./tools/backup_utils.sh list`
2. 选择合适备份：查看备份时间和描述
3. 执行恢复：`./tools/backup_utils.sh restore <备份文件> <目标文件>` 