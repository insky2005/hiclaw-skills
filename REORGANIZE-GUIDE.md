# 目录重组完成指南

## ✅ 重组完成

已将 `conversation-knowledge` 技能移动到多技能集合仓库 `hiclaw-skills/` 中。

---

## 📁 新目录结构

```
hiclaw-skills/                    # 多技能集合仓库
├── README.md                     # 仓库总览
├── package.json                  # NPM 风格配置
├── CONTRIBUTING.md               # 贡献指南
├── .gitignore                    # Git 忽略
├── REORGANIZE-GUIDE.md           # 本文件
└── skills/                       # 所有技能
    └── conversation-knowledge/   # 技能 1
        ├── README.md
        ├── SKILL.md
        ├── INSTALL.md
        ├── COMMANDS.md
        ├── QUICKSTART.md
        ├── LICENSE
        └── scripts/
```

---

## 🔗 符号链接更新

**重要**: 需要更新 HiClaw 的符号链接指向新位置！

```bash
# 1. 删除旧链接
rm -f /opt/hiclaw/agent/skills/conversation-knowledge

# 2. 创建新链接（指向新位置）
ln -s /root/manager-workspace/hiclaw-skills/skills/conversation-knowledge \
      /opt/hiclaw/agent/skills/conversation-knowledge

# 3. 验证
ls -la /opt/hiclaw/agent/skills/conversation-knowledge
```

---

## 📋 提交到 GitHub 的命令

### 方案 A：提交多技能集合仓库（推荐）

```bash
cd /root/manager-workspace/hiclaw-skills

# 1. 配置 Git 用户
git config user.email "your-email@example.com"
git config user.name "Your Name"

# 2. 创建提交
git commit -m "Initial commit: HiClaw Skills Collection

Skills:
- conversation-knowledge v1.0.0 - Conversation knowledge management

Structure:
- Multi-skill repository structure
- Each skill in skills/ directory
- Unified documentation and installation

License: MIT"

# 3. 重命名分支
git branch -M main

# 4. 在 GitHub 创建仓库后，添加远程
git remote add origin https://github.com/insky2005/hiclaw-skills.git

# 5. 推送
git push -u origin main
```

**GitHub 仓库名**: `hiclaw-skills`

---

### 方案 B：同时维护单技能仓库

如果想同时维护两个仓库：

```bash
# 多技能仓库
cd /root/manager-workspace/hiclaw-skills
git remote add origin https://github.com/insky2005/hiclaw-skills.git
git push -u origin main

# 单技能仓库（可选）
cd /root/manager-workspace/hiclaw-skills/skills/conversation-knowledge
git remote add origin https://github.com/insky2005/conversation-knowledge.git
git push -u origin main
```

---

## 📦 安装命令对比

### 多技能仓库（新）

```bash
# 从集合安装
skills install insky2005/hiclaw-skills/conversation-knowledge
```

### 单技能仓库（旧）

```bash
# 单独安装
skills install insky2005/conversation-knowledge
```

---

## 🔄 后续维护

### 添加新技能

```bash
# 1. 在 skills/ 目录下创建新技能
cd skills
mkdir new-skill-name

# 2. 添加技能文件
# ... 创建 scripts/, README.md, SKILL.md 等

# 3. 更新根目录 README.md
# 添加新技能到表格

# 4. 提交
git add .
git commit -m "feat: add new-skill-name"
git push
```

### 更新现有技能

```bash
# 修改技能文件
cd skills/conversation-knowledge
# ... 编辑文件

# 提交
cd ../..
git add .
git commit -m "fix: conversation-knowledge bug fix"
git push
```

---

## ✅ 检查清单

- [x] 创建 `hiclaw-skills/` 目录
- [x] 移动 `conversation-knowledge` 到 `skills/`
- [x] 创建仓库级文档（README, package.json, CONTRIBUTING）
- [x] 更新 conversation-knowledge 的安装说明
- [x] 初始化 Git 仓库
- [x] 添加所有文件到暂存区
- [ ] 配置 Git 用户信息
- [ ] 创建提交
- [ ] 在 GitHub 创建仓库
- [ ] 推送代码
- [ ] 更新 HiClaw 符号链接
- [ ] 测试技能功能

---

## 🎯 推荐下一步

1. **配置 Git 并提交**
   ```bash
   git config user.email "your-email@example.com"
   git config user.name "Your Name"
   git commit -m "Initial commit"
   ```

2. **在 GitHub 创建仓库**
   - 访问：https://github.com/new
   - 仓库名：`hiclaw-skills`
   - 不要初始化

3. **推送代码**
   ```bash
   git remote add origin https://github.com/insky2005/hiclaw-skills.git
   git push -u origin main
   ```

4. **更新符号链接**
   ```bash
   rm -f /opt/hiclaw/agent/skills/conversation-knowledge
   ln -s /root/manager-workspace/hiclaw-skills/skills/conversation-knowledge \
         /opt/hiclaw/agent/skills/conversation-knowledge
   ```

5. **测试**
   ```bash
   bash skills/conversation-knowledge/scripts/cmd.sh /帮助
   ```

---

## 📊 文件统计

| 类型 | 数量 |
|------|------|
| 根目录文件 | 5 |
| 技能文件 | 34 |
| 脚本文件 | 18 |
| 文档文件 | 16 |
| **总计** | **39** |

---

**重组完成！准备好提交到 GitHub 了吗？** 🚀
