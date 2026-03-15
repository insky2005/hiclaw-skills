# 安装指南 - Conversation Knowledge Skill

## 📋 前置要求

- HiClaw 或 OpenClaw 环境
- Bash shell
- jq (可选，用于更好的 JSON 处理)

---

## 🔧 安装步骤

### 方法 1：Git 克隆（推荐）

```bash
# 1. 克隆仓库
cd /root
git clone https://github.com/insky2005/conversation-knowledge.git .openclaw/skills/conversation-knowledge

# 2. 创建符号链接到 HiClaw skills 目录
ln -s /root/.openclaw/skills/conversation-knowledge /opt/hiclaw/agent/skills/conversation-knowledge

# 3. 确保脚本可执行
chmod +x /root/.openclaw/skills/conversation-knowledge/scripts/*.sh

# 4. 初始化知识库
bash /root/.openclaw/skills/conversation-knowledge/scripts/init-knowledge.sh
```

---

### 方法 2：直接复制

```bash
# 1. 下载并解压
# 从 GitHub 下载 ZIP 并解压到 ~/.openclaw/skills/conversation-knowledge

# 2. 创建符号链接
ln -s /root/.openclaw/skills/conversation-knowledge /opt/hiclaw/agent/skills/conversation-knowledge

# 3. 设置权限
chmod +x /root/.openclaw/skills/conversation-knowledge/scripts/*.sh

# 4. 初始化
bash /root/.openclaw/skills/conversation-knowledge/scripts/init-knowledge.sh
```

---

### 方法 3：HiClaw Skill Manager（如果可用）

```bash
# 使用 HiClaw 的 skill 管理命令
skills add insky2005/hiclaw-skills --skill conversation-knowledge
```

---

## ✅ 验证安装

```bash
# 1. 检查文件是否存在
ls -la /root/.openclaw/skills/conversation-knowledge/scripts/

# 2. 测试命令
bash /root/.openclaw/skills/conversation-knowledge/scripts/cmd.sh /帮助

# 3. 初始化知识库（交互式配置）

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/init-knowledge.sh
```

**初始化流程**：

1. 自动检测项目目录（`.agent` 或 `.openclaw` 的父目录）
2. 会提示输入知识库存储路径
3. 默认路径：`<project-directory>/.conversation-knowledge/`（项目目录下的隐藏文件夹）
4. 确认后自动创建目录结构
5. 生成配置文件：`scripts/.knowledge-config.json`

**示例**：
- 技能安装在：`/home/user/my-project/.agent/skills/conversation-knowledge/`
- 默认知识库：`/home/user/my-project/.conversation-knowledge/`

**重复初始化**：
- 如果已初始化，会显示当前配置
- 询问是否继续重新初始化
- 输入 `y` 继续，或 `N` 取消

# 4. 测试基本功能
bash /root/.openclaw/skills/conversation-knowledge/scripts/cmd.sh /列表
```

---

## 📁 目录结构

```
conversation-knowledge/
├── scripts/                    # 核心脚本
│   ├── cmd.sh                 # 命令入口
│   ├── smart-record.sh        # 智能记录
│   ├── context-tracker.sh     # 上下文追踪
│   ├── load-conversation.sh   # 加载话题
│   ├── search-knowledge.sh    # 搜索
│   ├── list-recent.sh         # 列表
│   ├── summarize-conversation.sh # 总结
│   ├── export-knowledge.sh    # 导出
│   ├── channel-switch.sh      # 渠道切换
│   ├── manage-topics.sh       # 话题管理
│   └── ...
├── README.md                   # 主文档
├── COMMANDS.md                 # 命令参考
├── QUICKSTART.md               # 快速开始
├── INSTALL.md                  # 本文件
└── LICENSE                     # 许可证
```

---

## 🔄 更新

```bash
# Git 安装方式
cd /root/.openclaw/skills/conversation-knowledge
git pull origin main

# 重新设置权限
chmod +x scripts/*.sh

# 测试
bash scripts/cmd.sh /帮助
```

---

## 🗑️ 卸载

```bash
# 1. 删除符号链接
rm /opt/hiclaw/agent/skills/conversation-knowledge

# 2. 删除技能文件
rm -rf /root/.openclaw/skills/conversation-knowledge

# 3. （可选）删除知识库数据
rm -rf /root/hiclaw-fs/shared/knowledge/conversations/
```

---

## 🐛 故障排除

### 问题 1：命令找不到

```bash
# 检查符号链接
ls -la /opt/hiclaw/agent/skills/ | grep conversation

# 重新创建
ln -s /root/.openclaw/skills/conversation-knowledge /opt/hiclaw/agent/skills/conversation-knowledge
```

### 问题 2：权限错误

```bash
# 设置执行权限
chmod +x /root/.openclaw/skills/conversation-knowledge/scripts/*.sh
```

### 问题 3：知识库未初始化

```bash
# 运行初始化
bash /root/.openclaw/skills/conversation-knowledge/scripts/init-knowledge.sh
```

---

## 📞 获取帮助

- 查看文档：`/帮助` 或 `/help`
- 提交 Issue：GitHub 仓库
- 社区支持：HiClaw Discord/论坛

---

**安装完成！** 🎉

开始使用：`/帮助`
