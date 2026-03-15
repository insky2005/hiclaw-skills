# Skills Install 故障排除指南

## ❌ 常见错误

### 错误 1: No skills found

```
┌   skills
│
◇  Repository cloned
│
◇  No skills found
│
└  No valid skills found. Skills require a SKILL.md with name and description.
```

**原因**: skills install 命令找不到有效的 SKILL.md 文件

**解决方案**:

1. **确保 SKILL.md 存在**
   ```bash
   ls -la skills/conversation-knowledge/SKILL.md
   ```

2. **检查 SKILL.md 格式**
   ```markdown
   ---
   name: conversation-knowledge
   description: Record, organize, and retrieve conversation knowledge
   ---
   
   # Skill Name
   ...
   ```

3. **确保 skills-index.json 存在**
   ```bash
   ls -la skills-index.json
   ```

---

## ✅ 正确的目录结构

### 多技能仓库结构

```
hiclaw-skills/
├── skills-index.json          # 技能集合索引（必需）
├── skills.json                # 技能列表（可选）
├── README.md
├── package.json
└── skills/                    # 所有技能
    ├── conversation-knowledge/
    │   ├── SKILL.md          # 每个技能必须有
    │   ├── README.md
    │   ├── scripts/
    │   └── ...
    └── other-skill/
        └── ...
```

---

## 🔧 skills install 工作原理

### 解析流程

1. **克隆仓库**
   ```bash
   git clone https://github.com/insky2005/hiclaw-skills.git
   ```

2. **查找技能索引**
   - 首先查找 `skills-index.json`
   - 然后查找 `skills.json`
   - 最后遍历 `skills/` 目录

3. **验证 SKILL.md**
   - 检查 YAML front matter
   - 必须有 `name` 和 `description`

4. **安装技能**
   - 复制到 `~/.openclaw/skills/`
   - 创建符号链接

---

## 📋 安装命令格式

### 从多技能仓库安装

```bash
# 格式
skills install username/repo/skill-name

# 示例
skills install insky2005/hiclaw-skills/conversation-knowledge
```

### 从单技能仓库安装

```bash
# 格式
skills install username/repo

# 示例
skills install insky2005/conversation-knowledge
```

---

## 🐛 调试步骤

### 步骤 1: 验证仓库结构

```bash
# 克隆仓库检查
git clone https://github.com/insky2005/hiclaw-skills.git
cd hiclaw-skills

# 检查必需文件
ls -la skills-index.json
ls -la skills/conversation-knowledge/SKILL.md
```

### 步骤 2: 验证 SKILL.md

```bash
# 查看 front matter
head -5 skills/conversation-knowledge/SKILL.md

# 应该有：
# ---
# name: conversation-knowledge
# description: ...
# ---
```

### 步骤 3: 测试安装

```bash
# 本地测试
skills install ./hiclaw-skills/conversation-knowledge

# 或从 GitHub
skills install insky2005/hiclaw-skills/conversation-knowledge
```

---

## 📦 skills-index.json 格式

```json
{
  "name": "hiclaw-skills-collection",
  "version": "1.1.0",
  "skills": [
    {
      "name": "conversation-knowledge",
      "path": "skills/conversation-knowledge",
      "description": "Record and manage conversations",
      "version": "1.1.0",
      "entryPoint": "scripts/cmd.sh"
    }
  ]
}
```

---

## 🎯 当前仓库结构

```
hiclaw-skills/
├── skills-index.json          ✅ 已创建
├── skills.json                ✅ 已创建
├── README.md                  ✅
├── package.json               ✅
└── skills/
    └── conversation-knowledge/
        ├── SKILL.md          ✅
        ├── README.md         ✅
        ├── INSTALL.md        ✅
        ├── scripts/          ✅
        └── ...
```

---

## 🔄 更新后的安装命令

```bash
# 现在应该可以正常安装
skills install insky2005/hiclaw-skills/conversation-knowledge
```

---

## 📞 仍然失败？

### 收集信息

1. **完整的错误信息**
2. **skills install 版本**
   ```bash
   skills --version
   ```
3. **Node.js 版本**
   ```bash
   node --version
   ```
4. **仓库 URL**
   ```bash
   git remote -v
   ```

### 替代安装方法

```bash
# 手动安装
git clone https://github.com/insky2005/hiclaw-skills.git
ln -s hiclaw-skills/skills/conversation-knowledge \
      ~/.openclaw/skills/conversation-knowledge

# 测试
bash hiclaw-skills/skills/conversation-knowledge/scripts/cmd.sh /帮助
```

---

**希望这能帮助解决问题！** 🚀
