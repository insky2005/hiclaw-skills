# 📋 更新日志 - Conversation Knowledge

## v1.1.3 (2026-03-15) - 项目目录自动检测

### ✨ 新增功能

#### 1. 智能项目目录检测
- ✅ 自动检测 `.agent` 或 `.openclaw` 目录
- ✅ 知识库默认存储在项目目录下
- ✅ 不再依赖技能目录位置

### 🐛 修复

#### 2. 默认路径优化
- ✅ 默认路径改为 `<project-directory>/.conversation-knowledge/`
- ✅ 技能安装在：`<project>/.agent/skills/conversation-knowledge/`
- ✅ 知识库在：`<project>/.conversation-knowledge/`
- ✅ 知识库与技能分离，更灵活

---

## v1.1.2 (2026-03-15) - 命令格式和默认路径优化

### 🐛 修复

#### 1. 默认路径优化
- ✅ 默认路径改为 `<skill-directory>/.conversation-knowledge/`
- ✅ 不再默认使用 `/root/hiclaw-fs/shared/knowledge/conversations`
- ✅ 更适合个人使用和技能隔离

### 📝 文档

#### 2. 命令格式修正
- ✅ `skills install` → `skills add --skill`
- ✅ 更新所有文档中的安装命令

---

## v1.1.0 (2026-03-15) - 配置优化

### ✨ 新增功能

#### 1. 交互式初始化配置
- ✅ 首次使用时必须初始化
- ✅ 提示用户提供知识库存储路径
- ✅ 支持自定义路径（不再硬编码）
- ✅ 路径验证和确认流程

#### 2. 重复初始化保护
- ✅ 检测是否已初始化
- ✅ 显示当前配置信息
- ✅ 询问是否继续重新初始化
- ✅ 备份现有 index.json

#### 3. 配置文件管理
- ✅ 生成 `.knowledge-config.json`
- ✅ 存储所有路径配置
- ✅ 支持手动编辑配置
- ✅ 版本控制和初始化时间记录

### 🔧 改进

#### 脚本更新
- `init-knowledge.sh` - 完全重写，支持交互式配置
- `context-tracker.sh` - 从配置文件读取路径
- 其他脚本逐步迁移到配置驱动

#### 用户体验
- 清晰的初始化步骤提示
- 路径推荐（HiClaw/独立使用）
- 配置确认流程
- 详细的完成总结

### 📚 文档

- ✅ 新增 `CONFIG-GUIDE.md` - 配置指南
- ✅ 更新 `INSTALL.md` - 初始化说明
- ✅ 更新 `CHANGELOG.md` - 本文件

### 🐛 修复

- 修复硬编码路径问题
- 修复重复初始化无提示问题
- 修复配置不可自定义问题

---

## v1.0.0 (2026-03-15) - 初始版本

### ✨ 核心功能

- 🤖 智能记录（自动提取主题和摘要）
- 🔄 上下文感知（加载后直接记录）
- 🔍 相似话题检测
- 📱 多渠道支持
- 📊 话题管理（合并/重命名/删除）
- 📤 多格式导出（Markdown/HTML/PDF）
- 🎯 简洁语法（空格分割）

### 📁 文件结构

- 18 个核心脚本
- 10+ 个文档文件
- 完整的命令系统

---

## 🔄 升级指南

### 从 v1.0.0 升级到 v1.1.0

1. **备份现有配置**
   ```bash
   cp -r /root/hiclaw-fs/shared/knowledge/conversations \
         /root/hiclaw-fs/shared/knowledge/conversations.backup
   ```

2. **更新脚本**
   ```bash
   cd /path/to/conversation-knowledge
   git pull origin main
   ```

3. **重新初始化**
   ```bash
   bash scripts/init-knowledge.sh
   ```
   - 会检测到现有配置
   - 询问是否继续
   - 输入 `y` 更新配置
   - 现有数据不会丢失

4. **验证**
   ```bash
   bash scripts/cmd.sh /列表
   ```

---

## 📊 版本对比

| 功能 | v1.0.0 | v1.1.0 | v1.1.2 | v1.1.3 |
|------|--------|--------|--------|--------|
| 硬编码路径 | ✅ | ❌ | ❌ | ❌ |
| 自定义路径 | ❌ | ✅ | ✅ | ✅ |
| 初始化确认 | ❌ | ✅ | ✅ | ✅ |
| 配置文件 | ❌ | ✅ | ✅ | ✅ |
| 重复初始化保护 | ❌ | ✅ | ✅ | ✅ |
| 配置备份 | ❌ | ✅ | ✅ | ✅ |
| 默认路径 | `/root/...` | `/root/...` | `<skill>/...` | `<project>/...` |
| 项目目录检测 | ❌ | ❌ | ❌ | ✅ |
| 正确命令格式 | ❌ | ❌ | ✅ | ✅ |

---

**Happy Knowledge Managing!** 📚✨
