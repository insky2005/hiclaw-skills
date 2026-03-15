# Natural Language Command Mapping

## 自然语言命令映射表

This document maps natural language phrases to skill commands.

---

## 📋 Initialization / 初始化

| User Says (CN) | User Says (EN) | Command | Action |
|----------------|----------------|---------|--------|
| 初始化知识库 | Initialize knowledge base | `/init` | Run `init-knowledge.sh` |
| 开始使用 | Start using | `/init` | Run initialization |
| 第一次使用 | First time use | `/init` | Run initialization |
| 配置知识库 | Configure knowledge base | `/init` | Run initialization |

---

## 📖 Load Topic / 加载话题

| User Says (CN) | User Says (EN) | Command | Action |
|----------------|----------------|---------|--------|
| 加载 XX 话题 | Load XX topic | `/加载 XX` | Set active topic context |
| 打开 XX | Open XX | `/加载 XX` | Load topic |
| 切换到 XX | Switch to XX | `/加载 XX` | Load topic |
| 我想记录关于 XX | I want to record about XX | `/加载 XX` | Load topic |
| 开始记录 XX | Start recording XX | `/加载 XX` | Load topic |

**Example**:
- User: "加载 AI 智能体分类"
- Command: `/加载 AI 智能体分类`
- Result: Topic context set for 1 hour

---

## 📝 Record / 记录

| User Says (CN) | User Says (EN) | Command | Action |
|----------------|----------------|---------|--------|
| 保存这段对话 | Save this conversation | `/记录 --summary "..."` | Record with context |
| 记录下来 | Record it | `/记录 --summary "..."` | Record |
| 记住这个 | Remember this | `/记录 --summary "..."` | Record |
| 添加到知识库 | Add to knowledge base | `/记录 --summary "..."` | Record |
| 记录对话 | Record conversation | `/记录 --summary "..."` | Record |
| 保存 | Save | `/记录 --summary "..."` | Record |

**With Context** (after loading topic):
- User: "保存这段对话，讨论了 XX"
- Command: `/记录 --summary "讨论了 XX"`
- Result: Auto-uses loaded topic

**Without Context**:
- User: "记录关于 XX 的讨论，摘要为..."
- Command: `/记录 --topic "XX" --summary "..."`

---

## 🔍 Search / 搜索

| User Says (CN) | User Says (EN) | Command | Action |
|----------------|----------------|---------|--------|
| 搜索 XX | Search XX | `/搜索 XX` | Search knowledge base |
| 查找关于 XX | Find about XX | `/搜索 XX` | Search |
| 有没有 XX 的记录 | Any records about XX | `/搜索 XX` | Search |
| 看看之前关于 XX 的讨论 | Show previous discussion about XX | `/搜索 XX` | Search |

**Example**:
- User: "搜索智能体分类"
- Command: `/搜索 智能体分类`
- Result: Search results with matches

---

## 📋 List / 列表

| User Says (CN) | User Says (EN) | Command | Action |
|----------------|----------------|---------|--------|
| 列出最近的对话 | List recent conversations | `/list` | Show recent |
| 最近记录了什么 | What was recorded recently | `/list` | Show recent |
| 查看最近的记录 | View recent records | `/list` | Show recent |
| 最近 7 天的对话 | Conversations from last 7 days | `/list 7` | List with days filter |

---

## 📊 Summarize / 总结

| User Says (CN) | User Says (EN) | Command | Action |
|----------------|----------------|---------|--------|
| 总结这个话题 | Summarize this topic | `/总结` | Summarize active topic |
| 总结一下 | Give me a summary | `/总结` | Summarize |
| XX 的摘要 | Summary of XX | `/总结 XX` | Summarize topic |
| 生成总结 | Generate summary | `/总结` | Summarize |

---

## 📤 Export / 导出

| User Says (CN) | User Says (EN) | Command | Action |
|----------------|----------------|---------|--------|
| 导出为 Markdown | Export as Markdown | `/导出 markdown` | Export |
| 导出 XX 话题 | Export XX topic | `/导出 XX` | Export topic |
| 保存为 PDF | Save as PDF | `/导出 PDF` | Export to PDF |
| 导出所有对话 | Export all conversations | `/导出 all` | Export all |

---

## 🎯 Context-Aware Recording

### Flow Example

1. **Load Topic**:
   - User: "加载 AI 智能体分类"
   - Command: `/加载 AI 智能体分类`
   - Context: Active for 1 hour

2. **Record (Auto-uses loaded topic)**:
   - User: "保存这段对话，讨论了市场分类"
   - Command: `/记录 --summary "讨论了市场分类"`
   - Result: Recorded to "AI 智能体分类" topic

3. **Record Another Entry** (still in context):
   - User: "又讨论了 L1-L5 分级"
   - Command: `/记录 --summary "又讨论了 L1-L5 分级"`
   - Result: Appended to same topic

---

## 🤖 LLM Integration Guide

### For Manager/LLM

When user sends a message, check for these patterns:

```python
# Pseudo-code for LLM decision

if "初始化" in message or "initialize" in message:
    action = "init_knowledge_base"
    command = "/init"

elif any(x in message for x in ["加载", "打开", "switch to", "load"]):
    topic = extract_topic(message)
    action = "load_topic"
    command = f"/加载 {topic}"

elif any(x in message for x in ["保存", "记录", "save", "record", "remember"]):
    if has_context():
        summary = extract_summary(message)
        command = f"/记录 --summary \"{summary}\""
    else:
        topic = extract_topic(message)
        summary = extract_summary(message)
        command = f"/记录 --topic \"{topic}\" --summary \"{summary}\""
    action = "record_conversation"

elif any(x in message for x in ["搜索", "查找", "search", "find"]):
    query = extract_query(message)
    action = "search"
    command = f"/搜索 {query}"

# ... and so on for other commands
```

### Trigger Conditions

**Always trigger skill when**:
- User explicitly uses slash commands (`/记录`, `/搜索`, etc.)
- User uses natural language phrases from the mapping table above
- Context is active and user wants to record

**Don't trigger when**:
- Casual conversation without knowledge management intent
- Questions about the skill itself (use `/帮助` instead)

---

## 📝 Examples

### Example 1: First-Time User

```
User: 我想使用对话知识管理
LLM: 好的！首先需要初始化知识库。请运行 `/初始化` 或点击这里的初始化按钮。
```

### Example 2: Recording with Context

```
User: 加载 AI 智能体分类
LLM: ✅ 已加载话题 "AI 智能体分类" (上下文有效期 1 小时)

User: 保存这段对话，我们讨论了 5 种分类方式
LLM: ✅ 已记录到 "AI 智能体分类"
   摘要：我们讨论了 5 种分类方式
   时间：2026-03-15 19:00
```

### Example 3: Search

```
User: 搜索关于智能体的讨论
LLM: 🔍 找到 3 条相关记录:
   1. AI 智能体分类 (2026-03-15)
   2. 智能体发展趋势 (2026-03-14)
   3. ...
```

---

## 🔧 Technical Implementation

### Command Parsing

```bash
# In cmd.sh

# Natural language detection
case "$CMD_NAME" in
  初始化|init|initialize)
    bash "$SCRIPT_DIR/init-knowledge.sh"
    ;;
  加载|load|open)
    bash "$SCRIPT_DIR/load-conversation.sh" "$@"
    ;;
  记录|record|save)
    bash "$SCRIPT_DIR/smart-record.sh" "$@"
    ;;
  # ... etc
esac
```

### Context Management

```bash
# In context-tracker.sh

# Set context (1 hour expiry)
set-topic "Topic Name"

# Get current context
current_topic=$(get-topic)

# Auto-use in record
if [ -n "$current_topic" ]; then
  TOPIC="$current_topic"
fi
```

---

**Last Updated**: 2026-03-15  
**Version**: v1.1.4
