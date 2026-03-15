# 🔧 诊断项目目录检测问题

## 问题描述

用户报告：PROJECT_DIR 仍然包含了 `.agent`

## 可能的原因

### 1. 配置文件已存在

如果之前初始化过，脚本会读取现有的配置文件，而不是重新检测。

**检查方法**：
```bash
# 查看配置文件
cat scripts/.knowledge-config.json

# 如果存在且路径不对，删除后重新初始化
rm scripts/.knowledge-config.json
bash scripts/init-knowledge.sh
```

### 2. 安装路径不是标准结构

技能可能没有安装在 `.agent/skills/` 或 `.openclaw/skills/` 下。

**检查方法**：
```bash
# 查看技能实际位置
pwd

# 完整路径应该类似：
# /home/user/project/.agent/skills/conversation-knowledge/scripts
# 或
# /home/user/project/.openclaw/skills/conversation-knowledge/scripts
```

### 3. 使用了 fallback 逻辑

如果没有找到 `.agent` 或 `.openclaw`，会使用 fallback（向上 3 级）。

**检查路径结构**：
```
scripts/                              ← 当前目录
└── conversation-knowledge/           ← +1 级
    └── skills/                       ← +2 级
        └── .agent/ 或 .openclaw/     ← +3 级（应该在这里找到）
            └── project/              ← 项目目录
```

---

## 诊断步骤

### 步骤 1：运行诊断脚本

```bash
bash /root/manager-workspace/hiclaw-skills/skills/conversation-knowledge/scripts/diagnose-project-dir.sh
```

### 步骤 2：检查输出

**正确输出**：
```
SCRIPT_DIR: /home/user/my-project/.agent/skills/conversation-knowledge/scripts
PROJECT_DIR: /home/user/my-project
DEFAULT_KNOWLEDGE_DIR: /home/user/my-project/.conversation-knowledge

✅ 正确：PROJECT_DIR 不包含 .agent
```

**错误输出**：
```
SCRIPT_DIR: /home/user/my-project/.agent/skills/conversation-knowledge/scripts
PROJECT_DIR: /home/user/my-project/.agent
DEFAULT_KNOWLEDGE_DIR: /home/user/my-project/.agent/.conversation-knowledge

❌ 错误：PROJECT_DIR 包含了 .agent
```

### 步骤 3：手动检测

```bash
# 进入技能目录
cd /path/to/your/project/.agent/skills/conversation-knowledge/scripts

# 运行检测
SCRIPT_DIR="$(pwd)"
echo "SCRIPT_DIR: $SCRIPT_DIR"

# 向上遍历
echo "Level 0: $(basename "$SCRIPT_DIR")"
echo "Level 1: $(basename "$(dirname "$SCRIPT_DIR")")"
echo "Level 2: $(basename "$(dirname "$(dirname "$SCRIPT_DIR")")")"
echo "Level 3: $(basename "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")"
echo "Level 4: $(basename "$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")")"
```

**期望输出**：
```
Level 0: scripts
Level 1: conversation-knowledge
Level 2: skills
Level 3: .agent          ← 找到这个，返回父目录
Level 4: my-project      ← 这应该是 PROJECT_DIR
```

---

## 解决方案

### 方案 1：删除配置文件重新初始化

```bash
cd /path/to/your/project/.agent/skills/conversation-knowledge/scripts
rm .knowledge-config.json
bash init-knowledge.sh
```

### 方案 2：手动指定路径

初始化时，当提示输入路径时，手动输入正确的项目目录：

```
Knowledge directory path [/wrong/path/.conversation-knowledge]: /home/user/my-project/.conversation-knowledge
```

### 方案 3：修改配置文件

```bash
# 编辑配置文件
nano scripts/.knowledge-config.json

# 修改 knowledge_dir 为正确路径
{
  "knowledge_dir": "/home/user/my-project/.conversation-knowledge",
  ...
}
```

---

## 报告问题时请提供

1. **技能完整路径**：
   ```bash
   pwd
   ```

2. **配置文件内容**：
   ```bash
   cat scripts/.knowledge-config.json
   ```

3. **诊断脚本输出**：
   ```bash
   bash scripts/diagnose-project-dir.sh
   ```

4. **目录结构**：
   ```bash
   ls -la ../../../
   ```

---

## 测试用例

### 测试用例 1：标准 .agent 安装

```
/home/user/my-project/
└── .agent/
    └── skills/
        └── conversation-knowledge/
            └── scripts/

期望：PROJECT_DIR = /home/user/my-project
```

### 测试用例 2：标准 .openclaw 安装

```
/home/user/project/
└── .openclaw/
    └── skills/
        └── conversation-knowledge/

期望：PROJECT_DIR = /home/user/project
```

### 测试用例 3：嵌套路径

```
/opt/apps/hiclaw/projects/test-project/
└── .agent/
    └── skills/
        └── conversation-knowledge/

期望：PROJECT_DIR = /opt/apps/hiclaw/projects/test-project
```

---

**如果问题仍然存在，请提供上述诊断信息！** 🔍
