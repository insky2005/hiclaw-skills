# Conversation Knowledge Skill 📚

**智能对话知识管理系统 - 支持多渠道、上下文感知的对话记录与知识管理**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![HiClaw](https://img.shields.io/badge/HiClaw-Skill-blue)](https://github.com/hiclaw/hiclaw)

---

## 🌟 特性亮点

- 🤖 **智能记录** - 自动提取主题和摘要，支持相似话题检测
- 🔄 **上下文感知** - 加载话题后直接记录，无需重复输入话题名
- 📱 **多渠道支持** - 钉钉/Telegram/Discord/Matrix 等多平台共享
- 🔍 **全文搜索** - 快速查找历史对话内容
- 📊 **话题管理** - 合并、重命名、删除话题
- 📤 **灵活导出** - Markdown/HTML/PDF 多种格式
- 🎯 **简洁语法** - 空格分割的命令，支持中英文

---

## 🚀 快速开始

### 1. 安装

将本技能目录复制到 HiClaw 的 skills 目录：

```bash
# 克隆或复制本仓库
git clone https://github.com/insky2005/conversation-knowledge.git

# 链接到 HiClaw skills 目录
ln -s /path/to/conversation-knowledge /root/.openclaw/skills/conversation-knowledge
```

### 2. 初始化

```bash
/init
```

### 3. 开始使用

```bash
# 加载话题
/加载 AI 智能体分类

# 记录对话（自动使用加载的话题）
/记录 --summary "讨论了新的分类方法"

# 搜索
/搜索 智能体

# 总结
/总结 AI 智能体分类

# 导出
/导出 AI 智能体分类 markdown
```

---

## 📋 核心命令

| 功能 | 命令 | 示例 |
|------|------|------|
| **加载话题** | `/加载 话题名 [格式]` | `/加载 AI 智能体分类 summary` |
| **记录对话** | `/记录 --summary "摘要"` | `/记录 --summary "讨论了 XXX"` |
| **搜索** | `/搜索 关键词` | `/搜索 智能体` |
| **列表** | `/列表 [天数] [数量]` | `/列表 7 10` |
| **总结** | `/总结 话题\|所有` | `/总结 AI 智能体分类` |
| **导出** | `/导出 话题 格式` | `/导出 AI markdown` |
| **帮助** | `/帮助` | `/help` |

---

## 🎯 完整工作流

### 场景 1：会议记录

```bash
# 会议开始前
/加载 项目规划会议

# 会议结束后记录
/记录 --summary "确定了项目时间表和里程碑"

# 导出分享
/导出 项目规划会议 markdown
```

### 场景 2：学习笔记

```bash
# 学习新知识点
/加载 AI 智能体分类

# 记录学习心得
/记录 --summary "学习了 5 种功能分类和 L1-L5 自主等级"

# 定期总结
/总结 AI 智能体分类
```

### 场景 3：多渠道协作

```bash
# 在钉钉讨论
/加载 项目讨论
/记录 --summary "钉钉会议的结论"

# 切换到 Telegram 继续
/切换 --from 钉钉 --to Telegram

# 在 Telegram 记录（自动关联同一话题）
/记录 --summary "Telegram 的补充讨论"

# 导出完整讨论记录
/导出 项目讨论 markdown
```

---

## 📚 文档

| 文档 | 说明 |
|------|------|
| [COMMANDS.md](COMMANDS.md) | 完整指令清单 |
| [QUICKSTART.md](QUICKSTART.md) | 快速开始指南 |
| [SYNTAX.md](SYNTAX.md) | 语法对比文档 |

---

## 🔧 技术架构

```
conversation-knowledge/
├── scripts/
│   ├── cmd.sh                    # 统一命令入口
│   ├── smart-record.sh           # 智能记录（上下文感知）
│   ├── context-tracker.sh        # 上下文追踪
│   ├── load-conversation.sh      # 加载话题
│   ├── search-knowledge.sh       # 搜索
│   ├── summarize-conversation.sh # 总结
│   └── ...
└── docs/
    ├── README.md
    ├── COMMANDS.md
    └── ...
```

**数据存储**:
- 技能脚本：`~/.openclaw/skills/conversation-knowledge/`
- 知识库数据：`/root/hiclaw-fs/shared/knowledge/conversations/` (MinIO 同步)

---

## 💡 高级功能

### 上下文感知

```bash
# 加载话题（设置 1 小时上下文）
/加载 AI 智能体分类

# 记录时自动使用该话题
/记录 --summary "讨论了新观点"
# ✅ 输出：Recording to active context: AI 智能体分类
```

### 智能话题检测

```bash
# 记录时自动检测相似话题
/记录 --topic "AI 讨论" --summary "新内容"

# 输出：
# ⚠️ Found 1 similar topic(s):
#    [1] AI 智能体分类
# 请选择：追加到现有话题 或 创建新话题
```

### 简洁语法

```bash
# 新语法（推荐）- 空格分割
/加载 AI 智能体分类 summary
/搜索 智能体 10
/列表 7 10

# 旧语法（仍支持）- 传统参数
/加载 --topic "AI" --format summary
/搜索 --query "智能体" --limit 10
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📝 更新日志

### v1.0.0 (2026-03-15)
- ✨ 初始版本
- 🤖 智能记录（自动提取主题和摘要）
- 🔄 上下文感知（加载后直接记录）
- 🔍 相似话题检测
- 📱 多渠道支持
- 📊 话题管理（合并/重命名/删除）
- 📤 多格式导出（Markdown/HTML/PDF）
- 🎯 简洁语法（空格分割）

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- [HiClaw](https://github.com/hiclaw/hiclaw) - AI 智能体管理平台
- [OpenClaw](https://github.com/openclaw/openclaw) - 底层框架

---

**Happy Knowledge Managing!** 📚✨
