# GitHub 提交指南 - Conversation Knowledge Skill

## 📋 提交前检查清单

### ✅ 文件准备

- [x] README.md - GitHub 风格的主文档
- [x] LICENSE - MIT 许可证
- [x] INSTALL.md - 安装指南
- [x] COMMANDS.md - 完整命令参考
- [x] QUICKSTART.md - 快速开始
- [x] SYNTAX.md - 语法对比
- [x] .gitignore - Git 忽略文件
- [x] scripts/ - 所有脚本文件

### ✅ 安全检查

- [ ] 检查脚本中是否有硬编码的路径
- [ ] 检查是否有 API 密钥或密码
- [ ] 检查是否有个人敏感信息
- [ ] 确认 .gitignore 已配置

---

## 🚀 提交步骤

### 步骤 1：准备仓库

```bash
# 进入技能目录
cd /root/manager-workspace/.openclaw/skills/conversation-knowledge

# 运行准备脚本
bash scripts/prepare-github.sh
```

---

### 步骤 2：创建 GitHub 仓库

1. 访问 https://github.com/new
2. 仓库名称：`conversation-knowledge`
3. 描述：`智能对话知识管理系统 - HiClaw Skill`
4. 可见性：Public（公开分享）
5. **不要** 勾选 "Initialize with README"（我们已有本地文件）
6. 点击 "Create repository"

---

### 步骤 3：本地 Git 配置

```bash
# 进入目录
cd /root/manager-workspace/.openclaw/skills/conversation-knowledge

# 查看状态
git status

# 添加所有文件
git add .

# 创建初始提交
git commit -m "Initial commit: conversation-knowledge skill

Features:
- Smart recording with auto topic extraction
- Context-aware conversation tracking
- Multi-channel support (DingTalk, Telegram, Discord, etc.)
- Full-text search
- Topic management (merge, rename, delete)
- Multiple export formats (Markdown, HTML, PDF)
- Simplified syntax with Chinese support

License: MIT"

# 重命名分支为 main
git branch -M main
```

---

### 步骤 4：关联远程仓库

```bash
# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/conversation-knowledge.git

# 验证远程
git remote -v
```

---

### 步骤 5：推送到 GitHub

```bash
# 推送
git push -u origin main

# 如果遇到认证问题，使用 Token：
# git push https://YOUR_GITHUB_TOKEN@github.com/YOUR_USERNAME/conversation-knowledge.git main
```

---

### 步骤 6：更新 README

推送后，编辑 GitHub 上的 README.md：

1. 在 GitHub 上点击 README.md
2. 点击编辑按钮（铅笔图标）
3. 替换 `YOUR_USERNAME` 为你的 GitHub 用户名
4. 替换仓库 URL 为你的实际 URL
5. 提交更改

---

## 📝 提交后的事情

### 1. 添加主题标签

在 GitHub 仓库页面添加 topics：
- `hiclaw`
- `skill`
- `conversation`
- `knowledge-management`
- `ai-agent`
- `chatbot`
- `productivity`

### 2. 创建 Release

```bash
# 打标签
git tag -a v1.0.0 -m "Release v1.0.0 - Initial public release"

# 推送标签
git push origin --tags
```

然后在 GitHub 上创建 Release：
1. 点击 "Releases" → "Create a new release"
2. 选择标签 v1.0.0
3. 填写发布说明
4. 点击 "Publish release"

### 3. 添加 Badge

在 README 中添加：

```markdown
[![Stars](https://img.shields.io/github/stars/YOUR_USERNAME/conversation-knowledge)](https://github.com/YOUR_USERNAME/conversation-knowledge/stargazers)
[![Forks](https://img.shields.io/github/forks/YOUR_USERNAME/conversation-knowledge)](https://github.com/YOUR_USERNAME/conversation-knowledge/network/members)
[![Issues](https://img.shields.io/github/issues/YOUR_USERNAME/conversation-knowledge)](https://github.com/YOUR_USERNAME/conversation-knowledge/issues)
```

---

## 🔄 后续更新

```bash
# 修改代码后
git add .
git commit -m "feat: 添加了新功能"
git push origin main
```

### 语义化版本

- `feat:` 新功能 → minor 版本
- `fix:` 修复 bug → patch 版本
- `BREAKING CHANGE:` 破坏性变更 → major 版本

---

## 📊 分享渠道

### 1. HiClaw 社区

- HiClaw GitHub Discussions
- HiClaw Discord 服务器
- HiClaw 技能市场（如果可用）

### 2. 社交媒体

- Twitter/X
- LinkedIn
- 技术博客

### 3. 相关论坛

- Reddit (r/opensource, r/productivity)
- Hacker News
- Product Hunt

---

## 🎯 README 优化建议

### 添加截图

```markdown
## 📸 截图

![Demo](screenshots/demo.gif)
```

### 添加使用示例

```markdown
## 💡 使用示例

### 会议记录
\`\`\`bash
/加载 项目会议
/记录 --summary "确定了里程碑"
/导出 项目会议 markdown
\`\`\`
```

### 添加贡献指南

```markdown
## 🤝 贡献

详见 [CONTRIBUTING.md](CONTRIBUTING.md)
```

---

## 🐛 常见问题

### Q: 推送失败，提示认证错误

**A:** 使用 GitHub Token 代替密码：
```bash
git push https://YOUR_USERNAME:YOUR_TOKEN@github.com/YOUR_USERNAME/conversation-knowledge.git
```

### Q: 如何更新已发布的技能？

**A:** 
1. 修改代码
2. `git add . && git commit -m "更新说明"`
3. `git push`
4. 通知用户更新

### Q: 有人提交了 Issue 怎么处理？

**A:**
1. 回复确认收到
2. 标记标签（bug/enhancement/question）
3. 尽快修复或给出时间表

---

## ✅ 最终检查

- [ ] README 中的 USERNAME 已替换
- [ ] 许可证文件存在
- [ ] 所有链接有效
- [ ] 代码无敏感信息
- [ ] .gitignore 配置正确
- [ ] 初始提交完成
- [ ] 推送到 GitHub
- [ ] 创建了 Release
- [ ] 添加了 Topics

---

**准备就绪！开始分享你的技能吧！** 🚀
