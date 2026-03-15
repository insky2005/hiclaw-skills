#!/bin/bash
# Demo: Context-Aware Recording

cat << 'EOF'
🎯 Context-Aware Recording Demo
================================

This feature allows seamless conversation recording by remembering
which topic you're currently viewing.

---

📋 WORKFLOW
-----------

Step 1: Load a topic
    /load --topic "AI 智能体分类"
    
    📖 Loading conversation: AI 智能体分类
    ...
    💡 Next actions:
       - Record: /record (will append to this topic)

Step 2: Have your discussion (in chat, meeting, etc.)

Step 3: Record (no need to specify topic!)
    /record --summary "讨论了 AI 分类的新观点"
    
    📍 Found active context: AI 智能体分类
    ✅ Recording to active context topic: "AI 智能体分类"
    ✅ Smart record complete!

---

✨ BENEFITS
-----------

1. No need to repeat topic name
2. Natural workflow: view → discuss → record
3. Context expires after 1 hour (auto-cleanup)
4. Can still override with explicit topic

---

🎪 EXAMPLES
-----------

# Example 1: Simple flow
/load --topic "Project Planning"
(record later)
/record --summary "Discussed timeline"

# Example 2: Override context
/load --topic "AI"
/record --topic "New Topic" --summary "..."  (creates new topic)

# Example 3: Force new topic despite context
/load --topic "AI"
/record --topic "AI" --summary "..." --new  (forces new entry)

---

🔧 TECHNICAL
------------

Context file: /root/hiclaw-fs/shared/knowledge/conversations/.context.json

Stores:
- current_topic: Topic name
- slug: Topic slug for file lookup
- set_at: When context was set
- expires_at: Auto-expires after 1 hour

Commands:
- context-tracker.sh set-topic "Name"
- context-tracker.sh get-topic
- context-tracker.sh clear
- context-tracker.sh show

---

💬 NATURAL LANGUAGE
-------------------

You can also say:
- "加载 AI 智能体话题" → /load
- "记一下" → /record (uses active context)
- "保存到当前话题" → /record (uses active context)

EOF
