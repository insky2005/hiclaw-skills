# 贡献指南 - HiClaw Skills Collection

欢迎贡献新技能！🎉

---

## 📋 技能要求

### 必需文件

- [ ] `README.md` - 技能说明和使用文档
- [ ] `SKILL.md` - 技能定义（HiClaw 格式）
- [ ] `scripts/` - 核心脚本目录
- [ ] `LICENSE` - 开源许可证（推荐 MIT）

### 推荐文件

- [ ] `INSTALL.md` - 安装指南
- [ ] `QUICKSTART.md` - 快速开始
- [ ] `.gitignore` - Git 忽略配置

---

## 🚀 创建新技能

### 1. 创建目录

```bash
cd skills
mkdir your-skill-name
cd your-skill-name
```

### 2. 基本结构

```
your-skill-name/
├── scripts/
│   ├── cmd.sh           # 命令入口
│   └── ...
├── README.md            # 主文档
├── SKILL.md            # 技能定义
├── LICENSE             # 许可证
└── .gitignore          # Git 忽略
```

### 3. SKILL.md 模板

```markdown
---
name: your-skill-name
description: Brief description of your skill
---

# Your Skill Name

## Overview

Description of what your skill does.

## Usage

Commands and examples.
```

---

## 📝 提交前检查

- [ ] 功能测试通过
- [ ] 文档完整
- [ ] 无敏感信息（API 密钥、密码等）
- [ ] 遵循 MIT 许可证
- [ ] 代码注释清晰
- [ ] 无硬编码路径

---

## 🔀 提交流程

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/your-skill`
3. 添加你的技能到 `skills/` 目录
4. 提交更改：`git commit -m "feat: add your-skill-name"`
5. 推送分支：`git push origin feature/your-skill`
6. 创建 Pull Request

---

## 📖 文档规范

### README.md

- 清晰的功能描述
- 安装步骤
- 使用示例
- 命令列表
- 常见问题

### 代码风格

- 使用 Bash 脚本（推荐）
- 添加注释
- 错误处理
- 避免硬编码

---

## 🧪 测试

确保你的技能：

- ✅ 在 HiClaw 环境中正常工作
- ✅ 不与其他技能冲突
- ✅ 错误处理完善
- ✅ 文档准确

---

## 💡 技能创意

不知道做什么技能？以下是一些想法：

- 🔍 **web-search** - 网络搜索集成
- 📅 **calendar-management** - 日历和日程管理
- 📧 **email-automation** - 邮件自动化
- 📊 **data-analysis** - 数据分析
- 🎨 **image-processing** - 图片处理
- 📝 **note-taking** - 笔记管理
- 🔔 **reminder-system** - 提醒系统
- 🌐 **translation** - 多语言翻译

---

## 🙏 感谢贡献

所有贡献者都会被记录在仓库的 CONTRIBUTORS 文件中。

---

**开始贡献吧！** 🚀
