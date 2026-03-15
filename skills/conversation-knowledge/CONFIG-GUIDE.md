# 配置指南 - Conversation Knowledge

## 📋 初始化配置

### 首次使用

运行初始化脚本时，会提示你配置知识库存储路径：

```bash
bash scripts/init-knowledge.sh
```

**交互流程**：

1. **检查是否已初始化**
   - 如果已初始化，会显示当前配置并询问是否继续
   - 输入 `y` 继续，或 `N` 取消

2. **配置知识库路径**
   ```
   Knowledge directory path [/root/hiclaw-fs/shared/knowledge/conversations]:
   ```
   - 输入自定义路径，或直接回车使用默认路径
   - 支持 `~` 展开为用户主目录

3. **确认配置**
   - 显示配置摘要
   - 输入 `Y` 确认，或 `n` 取消

4. **创建目录结构**
   - 自动创建所有必需的目录
   - 生成配置文件和索引文件

---

## 📁 配置文件

### .knowledge-config.json

**位置**: `scripts/.knowledge-config.json`

**内容**:
```json
{
  "knowledge_dir": "/root/hiclaw-fs/shared/knowledge/conversations",
  "topics_dir": "/root/hiclaw-fs/shared/knowledge/conversations/topics",
  "sessions_dir": "/root/hiclaw-fs/shared/knowledge/conversations/sessions",
  "exports_dir": "/root/hiclaw-fs/shared/knowledge/conversations/exports",
  "initialized_at": "2026-03-15T18:00:00+08:00",
  "version": "1.0.0",
  "script_dir": "/path/to/scripts"
}
```

**说明**:
- `knowledge_dir` - 知识库根目录（主要配置）
- `topics_dir` - 话题文件目录
- `sessions_dir` - 会话记录目录
- `exports_dir` - 导出文件目录
- `initialized_at` - 初始化时间
- `version` - 配置版本
- `script_dir` - 脚本所在目录

---

## 🔄 重新初始化

如果需要修改知识库路径：

```bash
bash scripts/init-knowledge.sh
```

**流程**：

1. 检测到已初始化
2. 显示当前配置
3. 询问是否继续：`Do you want to continue and reinitialize? (y/N)`
4. 输入 `y` 继续
5. 提供新的知识库路径
6. 确认配置
7. 更新配置文件

**注意**：
- 重新初始化不会删除现有数据
- 会备份现有的 `index.json`
- 会更新配置文件中的路径

---

## 🗑️ 完全重置

要完全重置配置：

```bash
# 删除配置文件
rm scripts/.knowledge-config.json

# 重新初始化
bash scripts/init-knowledge.sh
```

**警告**：这会删除配置信息，但不会删除知识库数据文件。

---

## 📊 目录结构

初始化后创建的目录结构：

```
<knowledge_dir>/
├── index.json              # 话题索引
├── .context.json           # 上下文追踪（临时）
├── topics/                 # 话题文件
│   ├── topic-1.md
│   └── topic-2.md
├── sessions/               # 会话记录
│   ├── 2026-03-15.md
│   └── 2026-03-16.md
└── exports/                # 导出文件
    ├── summary-20260315.md
    └── topic-export.md
```

---

## 🔧 手动修改配置

可以直接编辑 `scripts/.knowledge-config.json`：

```bash
# 打开配置文件
nano scripts/.knowledge-config.json

# 修改 knowledge_dir
{
  "knowledge_dir": "/new/path/to/knowledge"
}

# 保存后，所有脚本会自动使用新路径
```

---

## 💡 推荐路径

### 默认（推荐 - 自动检测）

```bash
<project-directory>/.conversation-knowledge/
```

**自动检测逻辑**：
- 技能安装在：`<project-directory>/.agent/skills/conversation-knowledge/`
- 或：`<project-directory>/.openclaw/skills/conversation-knowledge/`
- 知识库默认：`<project-directory>/.conversation-knowledge/`

**优点**：
- ✅ 自动检测项目目录
- ✅ 与项目一起管理
- ✅ 适合个人和团队使用
- ✅ 知识库独立于技能目录

### HiClaw 共享环境

```bash
/root/hiclaw-fs/shared/knowledge/conversations/
```

**优点**：
- ✅ 与 HiClaw 集成
- ✅ MinIO 自动同步
- ✅ 多渠道共享

### 独立使用

```bash
~/.conversation-knowledge/
```

**优点**：
- ✅ 独立于 HiClaw
- ✅ 易于备份
- ✅ 权限控制

### 项目特定

```bash
/path/to/project/knowledge/
```

**优点**：
- ✅ 项目隔离
- ✅ 版本控制友好

---

## ✅ 验证配置

### 检查配置文件

```bash
# 查看配置
cat scripts/.knowledge-config.json

# 或使用 jq
jq . scripts/.knowledge-config.json
```

### 测试功能

```bash
# 测试帮助
bash scripts/cmd.sh /帮助

# 测试列表
bash scripts/cmd.sh /列表

# 测试记录
bash scripts/cmd.sh /记录 --topic "测试" --summary "测试配置"
```

---

## 🐛 故障排除

### 问题 1：找不到配置文件

```bash
# 检查文件是否存在
ls -la scripts/.knowledge-config.json

# 如果不存在，重新初始化
bash scripts/init-knowledge.sh
```

### 问题 2：路径权限问题

```bash
# 检查目录权限
ls -la /path/to/knowledge/

# 修复权限
chmod -R 755 /path/to/knowledge/
chown -R $USER:$USER /path/to/knowledge/
```

### 问题 3：脚本使用旧路径

确保所有脚本都从配置文件读取路径：

```bash
# 检查脚本
grep "KNOWLEDGE_DIR" scripts/*.sh

# 应该看到引用 CONFIG_FILE 的行
```

---

## 📝 配置示例

### 示例 1：默认配置（项目目录下）

```json
{
  "knowledge_dir": "/home/user/my-project/.conversation-knowledge",
  "topics_dir": "/home/user/my-project/.conversation-knowledge/topics",
  "sessions_dir": "/home/user/my-project/.conversation-knowledge/sessions",
  "exports_dir": "/home/user/my-project/.conversation-knowledge/exports",
  "initialized_at": "2026-03-15T18:00:00+08:00",
  "version": "1.1.2",
  "script_dir": "/home/user/my-project/.agent/skills/conversation-knowledge/scripts"
}
```

**说明**：
- 项目目录：`/home/user/my-project/`
- 技能位置：`/home/user/my-project/.agent/skills/conversation-knowledge/`
- 知识库：`/home/user/my-project/.conversation-knowledge/`

### 示例 2：HiClaw 共享配置

```json
{
  "knowledge_dir": "/root/hiclaw-fs/shared/knowledge/conversations",
  "topics_dir": "/root/hiclaw-fs/shared/knowledge/conversations/topics",
  "sessions_dir": "/root/hiclaw-fs/shared/knowledge/conversations/sessions",
  "exports_dir": "/root/hiclaw-fs/shared/knowledge/conversations/exports",
  "initialized_at": "2026-03-15T18:00:00+08:00",
  "version": "1.1.2",
  "script_dir": "/opt/hiclaw/agent/skills/conversation-knowledge/scripts"
}
```

### 示例 3：独立使用配置

```json
{
  "knowledge_dir": "/home/user/.conversation-knowledge",
  "topics_dir": "/home/user/.conversation-knowledge/topics",
  "sessions_dir": "/home/user/.conversation-knowledge/sessions",
  "exports_dir": "/home/user/.conversation-knowledge/exports",
  "initialized_at": "2026-03-15T18:00:00+08:00",
  "version": "1.1.2",
  "script_dir": "/home/user/.openclaw/skills/conversation-knowledge/scripts"
}
```

---

## 🎯 最佳实践

1. **使用绝对路径** - 避免相对路径问题
2. **定期备份** - 备份整个 knowledge 目录
3. **权限控制** - 确保只有授权用户可以访问
4. **版本控制** - 将配置文件纳入版本管理
5. **文档化** - 记录自定义路径和原因

---

**配置完成！开始使用吧！** 🚀
