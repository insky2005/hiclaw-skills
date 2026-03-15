---
name: conversation-knowledge
description: Record, organize, and retrieve conversation knowledge across channels. Use when the human admin wants to save important discussions, search past conversations, or export knowledge summaries.
---

# Conversation Knowledge Management

## Overview

This skill maintains a searchable knowledge base of conversations between the Manager and human admin, organized by topic and accessible across all channels (DingTalk, Telegram, Discord, Matrix, etc.).

**Storage**: Configurable via `.knowledge-config.json` (default: `/root/hiclaw-fs/shared/knowledge/conversations/`)

**Skill Location**: `skills/conversation-knowledge/` in repository

**Quick Start**: `/help` or `/帮助`

**Command Format**: `/command` (supports Chinese & English)

**Requirements**:
- HiClaw >= 1.0.0
- Bash >= 4.0
- jq (optional, for better JSON handling)

---

## Step 1: Initialize Knowledge Base

Run once on first use:

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/init-knowledge.sh
```

Creates:
```
shared/knowledge/conversations/
├── index.json          # Topic index with metadata
├── topics/             # Topic-specific conversation logs
│   ├── {topic-slug}.md
│   └── ...
├── sessions/           # Raw session transcripts
│   └── YYYY-MM-DD.md
└── exports/            # Generated summaries/PDFs
    └── ...
```

---

## Step 2: Record a Conversation

**Trigger**: Admin says "save this", "remember this", or end of significant discussion.

### 2.1 Using Slash Commands (Recommended)

```
/record --topic "{topic-name}" --summary "{brief-summary}" --channel "{channel-type}"
/记录 --topic "{话题名}" --summary "{摘要}" --channel "dingtalk"
```

### 2.2 Using Script Directly

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/record-conversation.sh \
  --topic "{topic-name}" \
  --summary "{brief-summary}" \
  --channel "{channel-type}" \
  --session-key "{session-key}"
```

**Parameters**:
- `topic`: Main topic (e.g., "AI Agent Classification", "Project Planning")
- `summary`: 1-2 sentence abstract
- `channel`: dingtalk|telegram|discord|matrix|webchat
- `session-key`: Current session identifier (optional, for full transcript)

### 2.2 Auto-Categorize Topics

The script automatically:
1. Checks `index.json` for existing similar topics (fuzzy match)
2. Creates new topic file if no match found
3. Appends entry with timestamp to appropriate topic file

**Entry format** (in `topics/{topic-slug}.md`):
```markdown
## 2026-03-13 14:30 (dingtalk)

**摘要**: 讨论了市场上智能体的主要分类方式...

**关键点**:
- 按功能用途分为 5 类
- 按自主程度分为 L1-L5
- 当前趋势：从对话到行动

[[完整会话]](../sessions/2026-03-13.md#2026-03-13-14-30)
```

---

## Step 3: Search Conversations

**Trigger**: Admin asks about past discussions.

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/search-knowledge.sh \
  --query "{search-query}" \
  --topic "{optional-topic-filter}" \
  --since "{optional-date}" \
  --limit "{optional-limit}"
```

**Returns**: Ranked list of matching entries with:
- Topic name
- Date/time
- Channel
- Summary snippet
- Link to full transcript

---

## Step 4: Export Knowledge

**Trigger**: Admin requests summary or export.

### 4.1 Export by Topic

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/export-knowledge.sh \
  --topic "{topic-name}" \
  --format "markdown|pdf|html" \
  --output-path "{optional-custom-path}"
```

### 4.2 Export Time Range

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/export-knowledge.sh \
  --since "2026-03-01" \
  --until "2026-03-13" \
  --format "markdown"
```

### 4.3 Share via Channel

After export, share with admin:

```bash
# For DingTalk
[DINGTALK_FILE]{"path":"/root/hiclaw-fs/shared/knowledge/conversations/exports/{filename}.md","fileName":"{filename}.md","fileType":"md"}[/DINGTALK_FILE]

# For other channels, use message tool
message --channel telegram --target "{chat-id}" --file "{path}"
```

---

## Step 5: List Recent Conversations

**Trigger**: Admin says "列出最近的对话", "show recent conversations".

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/list-recent.sh \
  --days 7 \
  --limit 10 \
  --channel "{optional-channel-filter}"
```

**Returns**: Chronological list of recent conversations by topic and date.

---

## Step 6: Load Specific Conversation

**Trigger**: Admin says "加载 XXX 话题", "load conversation XXX".

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/load-conversation.sh \
  --topic "{topic-name}" \
  --format "full|summary|timeline"
```

**Formats**:
- `full`: Complete conversation log with all details
- `summary`: Only summaries and key points
- `timeline`: Chronological list of entries

---

## Step 7: Summarize Conversations

**Trigger**: Admin says "总结一下 XXX", "summarize this topic".

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/summarize-conversation.sh \
  --topic "{topic-name}" \
  --all  # OR summarize all topics
  --output "{optional-path}"
```

**Features**:
- Extracts key points from all entries
- Generates timeline
- Creates shareable summary document

---

## Step 8: Channel Switch Helper

**Trigger**: Admin switches channels, says "切换到微信，带上之前的上下文".

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/channel-switch.sh \
  --from "{old-channel}" \
  --to "{new-channel}" \
  --topic "{optional-topic}" \
  --lines 20
```

**Purpose**: Provides conversation continuity when switching between channels (DingTalk → Telegram → Discord, etc.). Shows recent context and suggests topics to reference.

---

## Step 9: Topic Management

### 9.1 Merge Topics

When admin says "merge topic A and B":

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/manage-topics.sh \
  --action merge \
  --from "{topic-a}" "{topic-b}" \
  --to "{merged-topic-name}"
```

### 9.2 Rename Topic

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/manage-topics.sh \
  --action rename \
  --from "{old-name}" \
  --to "{new-name}"
```

### 9.3 List All Topics

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/manage-topics.sh --action list
```

### 9.4 Delete Topic

```bash
bash /root/.openclaw/skills/conversation-knowledge/scripts/manage-topics.sh \
  --action delete \
  --from "{topic-name}"
```

---

## Index Structure (index.json)

```json
{
  "topics": [
    {
      "slug": "ai-agent-classification",
      "name": "AI 智能体分类",
      "entry_count": 3,
      "first_recorded": "2026-03-13T14:30:00+08:00",
      "last_updated": "2026-03-13T16:45:00+08:00",
      "channels": ["dingtalk", "matrix"],
      "tags": ["AI", "智能体", "分类"]
    }
  ],
  "total_entries": 15,
  "updated_at": "2026-03-13T16:45:00+08:00"
}
```

---

## Session Transcript Format (sessions/YYYY-MM-DD.md)

```markdown
# 2026-03-13 Conversations

## 14:30 (dingtalk)

**User**: 帮我总结一下，目前市场上有哪几大类智能体。

**Manager**: [full response...]

---

## 16:45 (matrix)

**User**: 当我和你沟通时，能不能按相似主题，整理成一份总结文件...

**Manager**: [full response...]
```

---

## Automatic Recording (Optional)

Enable auto-recording for all conversations:

```bash
# Set in Manager's openclaw.json or environment
CONVERSATION_KNOWLEDGE_AUTO_RECORD=true
CONVERSATION_KNOWLEDGE_MIN_LENGTH=5  # Minimum messages to record
```

When enabled, automatically records conversations that:
- Have more than N message exchanges
- Contain keywords: "总结", "记住", "保存", "record", "remember", "save"
- Are explicitly marked by admin

---

## Usage Examples

| Admin Says | Action |
|------------|--------|
| "把刚才的对话保存一下" | `record-conversation.sh` with extracted topic |
| "我们之前聊过智能体分类吗？" | `search-knowledge.sh --query "智能体分类"` |
| "列出最近的对话" | `list-recent.sh --days 7` |
| "加载 AI 智能体话题" | `load-conversation.sh --topic "AI 智能体分类"` |
| "总结一下这个项目讨论" | `summarize-conversation.sh --topic "Project Planning"` |
| "切换到微信，带上上下文" | `channel-switch.sh --from dingtalk --to wechat` |
| "导出这个月所有的讨论" | `export-knowledge.sh --since 2026-03-01 --format markdown` |
| "有哪些话题类别？" | `manage-topics.sh --action list` |
| "把 AI 和智能体两个话题合并" | `manage-topics.sh --action merge` |
| "显示快速参考" | `quickref.sh` |

---

## Notes

- All files are stored in `/root/hiclaw-fs/shared/` for MinIO sync
- Exports are available to all channels
- Topic slugs are URL-safe (lowercase, hyphens)
- Timestamps use Asia/Shanghai timezone (configurable)
