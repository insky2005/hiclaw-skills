# 🚀 推送到 GitHub 指南

## ✅ 本地提交已完成

**提交信息**:
```
Initial commit: HiClaw Skills Collection

Skills:
- conversation-knowledge v1.0.0

Features:
- Multi-skill repository structure
- Smart recording with context awareness
- Multi-channel support
- Full-text search and topic management
- Multiple export formats
- Simplified syntax with Chinese/English support

License: MIT
```

**提交哈希**: `89e982e`
**分支**: `main`
**远程**: `https://github.com/insky2005/hiclaw-skills.git`

---

## 🔐 推送方法（选择一种）

### 方法 1：使用 GitHub Token（推荐）

#### 步骤 1：生成 Personal Access Token

1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 填写说明：`hiclaw-skills push`
4. 选择权限：
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
5. 点击 "Generate token"
6. **复制 Token**（只显示一次！）- 格式：`ghp_xxxxxxxxxxxx`

#### 步骤 2：使用 Token 推送

```bash
cd /root/manager-workspace/hiclaw-skills

# 使用 Token 推送（替换 YOUR_TOKEN 为你的实际 Token）
git push https://insky2005:ghp_xxxxxxxxxxxx@github.com/insky2005/hiclaw-skills.git main
```

---

### 方法 2：配置 SSH 密钥

#### 步骤 1：生成 SSH 密钥

```bash
# 生成新的 SSH 密钥
ssh-keygen -t ed25519 -C "your-email@example.com"

# 按回车接受默认位置
# 可选：设置密码短语
```

#### 步骤 2：添加 SSH 密钥到 GitHub

1. 查看公钥：
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. 复制输出内容（以 `ssh-ed25519` 开头）
3. 访问：https://github.com/settings/keys
4. 点击 "New SSH key"
5. 标题：`hiclaw-skills`
6. 粘贴公钥内容
7. 点击 "Add SSH key"

#### 步骤 3：测试 SSH 连接

```bash
ssh -T git@github.com
# 应该看到：Hi insky2005! You've successfully authenticated...
```

#### 步骤 4：推送

```bash
cd /root/manager-workspace/hiclaw-skills
git push -u origin main
```

---

### 方法 3：在 GitHub 上创建仓库后手动上传

如果上述方法都不可用，可以：

#### 步骤 1：在 GitHub 创建空仓库

1. 访问：https://github.com/new
2. 仓库名：`hiclaw-skills`
3. 描述：`HiClaw Skills Collection`
4. 可见性：Public
5. ❌ 不要勾选 "Initialize with README"
6. 点击 "Create repository"

#### 步骤 2：下载代码压缩包

```bash
cd /root/manager-workspace
tar -czf hiclaw-skills.tar.gz hiclaw-skills/
```

然后手动上传到 GitHub（不推荐，会丢失 Git 历史）。

---

## ✅ 推送成功后的验证

推送成功后，访问：
```
https://github.com/insky2005/hiclaw-skills
```

检查：
- [ ] 所有文件都已上传（39 个文件）
- [ ] README.md 显示正常
- [ ] 提交历史显示 "Initial commit"
- [ ] 分支为 `main`

---

## 📦 安装测试

推送成功后，测试安装命令：

```bash
# 安装技能（未来用户会使用这个命令）
skills add insky2005/hiclaw-skills --skill conversation-knowledge
```

---

## 🎯 推荐操作

**推荐使用方法 1（GitHub Token）**，因为：
- ✅ 简单快速
- ✅ 不需要配置 SSH
- ✅ 适合一次性推送

**长期维护建议配置 SSH 密钥**，更方便。

---

## 📞 需要帮助？

如果遇到任何问题：
1. 检查 Token 权限是否正确
2. 确认仓库名正确：`insky2005/hiclaw-skills`
3. 检查网络连接
4. 查看 Git 错误信息

---

**准备好推送了吗？** 选择一种方法执行即可！🚀
