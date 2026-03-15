# HiClaw Skills Collection 📚

**智能体技能集合 - 为 HiClaw/OpenClaw 设计的实用技能**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![HiClaw](https://img.shields.io/badge/HiClaw-Skill-blue)](https://github.com/hiclaw/hiclaw)

---

## 🌟 特性

- 🧩 **模块化设计** - 每个技能独立，按需安装
- 🚀 **简易安装** - 一行命令即可安装
- 🔄 **持续更新** - 定期添加新技能
- 📚 **完整文档** - 每个技能都有详细说明
- 🤝 **社区驱动** - 欢迎贡献新技能

---

## 📦 可用技能

| 技能 | 描述 | 版本 | 安装命令 |
|------|------|------|----------|
| **[conversation-knowledge]**(skills/conversation-knowledge/) | 对话知识管理 - 智能记录、搜索、总结对话 | v1.0.0 | `skills install USER/hiclaw-skills/conversation-knowledge` |

### 即将推出

- `github-operations` - GitHub 操作自动化
- `file-sync` - 文件同步与管理
- `web-search` - 网络搜索集成
- `calendar-management` - 日历和日程管理

---

## 🚀 快速安装

### 安装单个技能

```bash
# 从 GitHub 安装
skills install insky2005/hiclaw-skills/conversation-knowledge

# 或使用 npx（如果支持）
npx @hiclaw/skills install insky2005/hiclaw-skills/conversation-knowledge

# 或手动安装
git clone https://github.com/insky2005/hiclaw-skills.git
ln -s hiclaw-skills/skills/conversation-knowledge ~/.openclaw/skills/conversation-knowledge
```

### 初始化技能

```bash
# 安装后初始化
/初始化
```

---

## 📚 技能文档

每个技能都有自己的完整文档：

- **[conversation-knowledge](skills/conversation-knowledge/)**
  - [安装指南](skills/conversation-knowledge/INSTALL.md)
  - [快速开始](skills/conversation-knowledge/QUICKSTART.md)
  - [命令参考](skills/conversation-knowledge/COMMANDS.md)
  - [语法说明](skills/conversation-knowledge/SYNTAX.md)

---

## 💡 使用示例

### conversation-knowledge

```bash
# 加载话题
/加载 AI 智能体分类

# 记录对话（自动使用上下文）
/记录 --summary "讨论了新的分类方法"

# 搜索
/搜索 智能体

# 总结
/总结 AI 智能体分类

# 导出
/导出 AI 智能体分类 markdown
```

---

## 🤝 贡献技能

欢迎提交新的技能！

### 技能结构

```
skills/your-skill/
├── scripts/           # 核心脚本
│   ├── cmd.sh        # 命令入口
│   └── ...
├── README.md          # 技能文档
├── SKILL.md          # 技能定义
└── ...
```

### 提交流程

1. Fork 本仓库
2. 在 `skills/` 目录下创建新技能
3. 编写完整文档（README、INSTALL 等）
4. 测试技能功能
5. 提交 Pull Request

### 技能要求

- ✅ 独立功能，不依赖其他技能
- ✅ 完整的文档（README + INSTALL）
- ✅ MIT 或其他开源许可证
- ✅ 通过 HiClaw 技能测试
- ✅ 无敏感信息

---

## 🔧 开发环境

### 本地测试

```bash
# 克隆仓库
git clone https://github.com/insky2005/hiclaw-skills.git
cd hiclaw-skills

# 链接到 HiClaw
ln -s $(pwd)/skills/conversation-knowledge ~/.openclaw/skills/conversation-knowledge

# 测试技能
bash skills/conversation-knowledge/scripts/cmd.sh /帮助
```

### 运行测试

```bash
# 如果有测试套件
npm test
# 或
bash tests/run-tests.sh
```

---

## 📊 统计

| 指标 | 数值 |
|------|------|
| 技能数量 | 1 |
| 总下载量 | - |
| 贡献者 | 1 |
| 许可证 | MIT |

---

## 🙏 致谢

- [HiClaw](https://github.com/hiclaw/hiclaw) - AI 智能体管理平台
- [OpenClaw](https://github.com/openclaw/openclaw) - 底层框架
- 所有贡献者

---

## 📄 许可证

MIT License - 详见每个技能的 LICENSE 文件

---

## 🔗 链接

- **GitHub**: https://github.com/insky2005/hiclaw-skills
- **HiClaw 文档**: https://github.com/hiclaw/hiclaw
- **问题反馈**: https://github.com/insky2005/hiclaw-skills/issues

---

**Happy Skill Building!** 🚀✨
