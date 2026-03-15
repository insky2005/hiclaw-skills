#!/bin/bash
# Show quick reference for conversation-knowledge commands

cat << 'EOF'
📚 Conversation Knowledge - Quick Reference
============================================

📋 SLASH COMMANDS (Recommended)
-------------------------------
Use /command format, supports Chinese & English

# Initialize
/init or /初始化

# Record conversation
/record --topic "Topic" --summary "Summary" --channel "dingtalk"
/记录 --topic "话题" --summary "摘要"

# Search
/search --query "keyword"
/搜索 --query "关键词"

# List recent
/list --days 7
/列出 --days 7
/recent or /最近

# Load topic
/load --topic "Topic Name"
/加载 --topic "话题名"

# Summarize
/summarize --topic "Topic"
/总结 --topic "话题"
/summarize --all or /总结 --all

# Export
/export --topic "Topic" --format markdown
/导出 --topic "话题"

# Channel switch
/switch --from dingtalk --to telegram
/切换 --from 钉钉 --to 微信

# Manage topics
/topics --action list
/话题 --action list

# Help
/help or /帮助

---

📋 DIRECT SCRIPT CALLS (Alternative)
------------------------------------

# Initialize (run once)
bash init-knowledge.sh

# Record a conversation
bash record-conversation.sh \
  --topic "Topic Name" \
  --summary "Brief summary" \
  --channel "dingtalk|telegram|discord|matrix" \
  --keypoints "- Point 1\n- Point 2"

# Search conversations
bash search-knowledge.sh --query "keyword"
bash search-knowledge.sh --topic "Topic Name"

# List recent conversations
bash list-recent.sh [--days 7] [--limit 10]
bash list-recent.sh --channel "dingtalk"

# Load a specific topic
bash load-conversation.sh --topic "Topic Name"
bash load-conversation.sh --topic "Topic Name" --format summary|timeline|full

# Summarize conversations
bash summarize-conversation.sh --topic "Topic Name"
bash summarize-conversation.sh --all

# Export conversations
bash export-knowledge.sh --topic "Topic Name" --format markdown|html|pdf
bash export-knowledge.sh --since "2026-03-01" --until "2026-03-15"

# Manage topics
bash manage-topics.sh --action list
bash manage-topics.sh --action merge --from "A" "B" --to "Merged"
bash manage-topics.sh --action rename --from "Old" --to "New"

# Channel switch helper
bash channel-switch.sh --from "dingtalk" --to "telegram"
bash channel-switch.sh --topic "Topic Name"


💬 NATURAL LANGUAGE TRIGGERS
----------------------------

Say these to trigger actions:

| You Say | Action |
|---------|--------|
| "把刚才的对话保存一下" | record-conversation |
| "我们之前聊过 XXX 吗？" | search-knowledge --query "XXX" |
| "列出最近的对话" | list-recent |
| "加载 XXX 话题" | load-conversation --topic "XXX" |
| "总结一下 XXX" | summarize-conversation --topic "XXX" |
| "导出所有对话" | export-knowledge --all |
| "切换到微信，带上之前的上下文" | channel-switch |
| "有哪些话题类别？" | manage-topics --action list |
| "把 A 和 B 合并" | manage-topics --action merge |


🔄 MULTI-CHANNEL WORKFLOW
-------------------------

1. **Before switching channels:**
   ```bash
   bash channel-switch.sh --from "dingtalk" --to "telegram"
   ```

2. **In new channel, reference recent context:**
   - "继续我们刚才关于 XXX 的讨论"
   - "上次在钉钉聊到 XXX，现在..."

3. **After important discussion:**
   ```bash
   bash record-conversation.sh --topic "XXX" --channel "telegram"
   ```

4. **End of day - export summary:**
   ```bash
   bash summarize-conversation.sh --all --output /path/to/daily-summary.md
   ```


📁 FILE STRUCTURE
-----------------

/root/hiclaw-fs/shared/knowledge/conversations/
├── index.json          # Topic index with metadata
├── topics/             # Per-topic conversation logs
│   ├── ai-agent-classification.md
│   └── project-planning.md
├── sessions/           # Daily raw transcripts
│   ├── 2026-03-15.md
│   └── 2026-03-14.md
└── exports/            # Generated summaries
    ├── summary-20260315_103000.md
    └── topic-ai-20260315_104500.md


⚙️ CONFIGURATION (Optional)
---------------------------

Add to Manager's openclaw.json:

```json
{
  "conversationKnowledge": {
    "autoRecord": true,
    "minMessages": 5,
    "defaultChannel": "dingtalk",
    "timezone": "Asia/Shanghai"
  }
}
```


🎯 EXAMPLES
-----------

# Record today's AI discussion
bash record-conversation.sh \
  --topic "AI 智能体分类" \
  --summary "讨论了市场主流智能体分类方式" \
  --channel "dingtalk" \
  --keypoints "- 5 种功能类型\n- L1-L5 自主等级"

# Search for project discussions
bash search-knowledge.sh --query "项目" --limit 5

# Load and summarize a topic
bash load-conversation.sh --topic "AI 智能体分类" --format summary

# Export this week's conversations
bash export-knowledge.sh --since "2026-03-10" --format markdown

# See all topics
bash manage-topics.sh --action list

EOF
