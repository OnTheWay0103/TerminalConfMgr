# 单仓库设计说明

## 设计目标

实现工具脚本和用户配置文件在同一个 Git 仓库中管理，简化部署和使用流程。

## 当前设计分析

### 现有问题

1. **双仓库结构**：
   - 工具仓库：包含 `install.sh`、`dotconf.sh` 等工具
   - 用户仓库：`~/.dotfiles` 包含用户配置文件
2. **部署复杂**：
   - 需要先克隆工具仓库
   - 再初始化用户仓库
   - 两个仓库需要分别管理

### 目标设计

1. **单仓库结构**：

   - 工具脚本和配置文件在同一个仓库
   - 一个仓库包含所有内容

2. **简化部署**：
   - 克隆一个仓库即可
   - 自动安装和配置

## 新的仓库结构

```
dotfiles/
├── tools/                    # 工具脚本目录
│   ├── install.sh           # 安装脚本
│   ├── dotconf.sh           # 主工具脚本
│   └── demo_remote_sync.sh  # 演示脚本
├── configs/                  # 配置文件目录
│   ├── shell/               # Shell 配置
│   │   ├── .zshrc
│   │   ├── .bashrc
│   │   └── .zshrc_custom
│   ├── git/                 # Git 配置
│   │   └── .gitconfig
│   ├── editor/              # 编辑器配置
│   │   ├── .vimrc
│   │   └── .config/nvim/
│   └── system/              # 系统配置
│       └── .config/
├── docs/                     # 文档目录
│   ├── README.md
│   ├── COMPATIBILITY.md
│   ├── REMOTE_SYNC.md
│   └── REPOSITORY_DESIGN.md
├── templates/                # 配置模板
│   ├── basic/
│   ├── developer/
│   └── minimal/
├── scripts/                  # 辅助脚本
│   ├── setup.sh
│   └── migrate.sh
└── .gitignore
```

## 实现方案

### 方案 1: 重构现有工具（推荐）

1. **修改 `dotconf.sh`**：

   - 不再创建独立的 `~/.dotfiles` 仓库
   - 直接在当前仓库中管理配置文件
   - 配置文件存储在 `configs/` 目录

2. **修改 `install.sh`**：

   - 安装工具到系统 PATH
   - 创建符号链接到当前仓库的配置文件

3. **优势**：
   - 真正的单仓库设计
   - 简化部署流程
   - 便于版本控制

### 方案 2: 保持现有结构

1. **当前设计**：

   - 工具仓库 + 用户仓库
   - 通过 `dotconf.sh` 管理用户仓库

2. **改进点**：
   - 优化工具仓库结构
   - 提供更好的模板和示例
   - 简化初始化流程

## 推荐实现

### 步骤 1: 重构仓库结构

```bash
# 创建新的目录结构
mkdir -p tools configs docs templates scripts

# 移动文件到对应目录
mv install.sh tools/
mv dotconf.sh tools/
mv demo_remote_sync.sh tools/
mv README.md docs/
mv COMPATIBILITY.md docs/
mv REMOTE_SYNC.md docs/
```

### 步骤 2: 修改工具脚本

1. **更新 `tools/install.sh`**：

   - 安装工具到系统 PATH
   - 创建符号链接到配置文件

2. **更新 `tools/dotconf.sh`**：
   - 配置文件路径改为 `configs/`
   - 符号链接指向当前仓库

### 步骤 3: 创建配置模板

```bash
# 创建基础配置模板
mkdir -p templates/basic
cp configs/shell/.zshrc templates/basic/
cp configs/git/.gitconfig templates/basic/
```

## 使用流程

### 新用户使用流程

```bash
# 1. 克隆仓库
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles

# 2. 安装工具
./tools/install.sh

# 3. 初始化配置
dotf init

# 4. 自定义配置
# 编辑 configs/ 目录下的文件

# 5. 同步到远程
dotf sync
```

### 现有用户迁移流程

```bash
# 1. 备份现有配置
dotf backup

# 2. 克隆新仓库
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles

# 3. 迁移配置
./scripts/migrate.sh

# 4. 验证配置
dotf status
```

## 优势对比

| 方面       | 当前设计 | 新设计 |
| ---------- | -------- | ------ |
| 仓库数量   | 2 个     | 1 个   |
| 部署复杂度 | 中等     | 简单   |
| 维护难度   | 中等     | 简单   |
| 版本控制   | 分离     | 统一   |
| 学习成本   | 中等     | 低     |

## 实施计划

### 阶段 1: 准备阶段

- [ ] 创建新的目录结构
- [ ] 移动现有文件
- [ ] 更新 .gitignore

### 阶段 2: 重构工具

- [ ] 修改 install.sh
- [ ] 修改 dotconf.sh
- [ ] 创建配置模板

### 阶段 3: 测试验证

- [ ] 测试安装流程
- [ ] 测试配置管理
- [ ] 测试远程同步

### 阶段 4: 文档更新

- [ ] 更新 README.md
- [ ] 更新使用说明
- [ ] 创建迁移指南

## 总结

单仓库设计将大大简化用户的使用体验，实现真正的"一个仓库管理所有"的目标。通过合理的目录结构和工具重构，我们可以提供更简单、更直观的配置文件管理方案。
