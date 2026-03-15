#!/bin/bash
# Conversation Knowledge - Command Dispatcher
# Simplified syntax with space-separated arguments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Show help
show_help() {
  cat << 'EOF'
📚 Conversation Knowledge Commands (Simplified)
=================================================

Usage: /command [arguments]

All commands support both new (simplified) and old (traditional) syntax.

---

📋 BASIC COMMANDS
-----------------
  /init, /初始化              Initialize knowledge base

  /help, /帮助                Show this help message

---

📖 LOAD (Simplified)
  /load, /加载                Load topic (sets active context)
    
    New: /load Topic Name [format]
    Old: /load --topic "Name" --format full
    
    Examples:
      /加载 AI 智能体分类
      /加载 AI 智能体分类 summary
      /load Project Planning full

---

📝 RECORD (Context-Aware)
  /record, /记录              Record conversation
    
    With context:
      /加载 AI 智能体
      /记录 --summary "讨论了..."  (auto-uses AI 智能体)
    
    Manual:
      /记录 --topic "话题" --summary "摘要"
      /记录 --topic "AI" --summary "新" --new

---

🔍 SEARCH (Simplified)
  /search, /搜索              Search conversations
    
    New: /搜索 keyword [topic_filter] [limit]
    Old: /search --query "keyword" --topic "Name"
    
    Examples:
      /搜索 智能体
      /搜索 AI 10
      /搜索 --query "AI" --topic "分类"

---

📋 LIST (Simplified)
  /list, /列出                List recent conversations
    
    New: /list [days] [limit] [channel]
    Old: /list --days 7 --limit 10
    
    Examples:
      /list
      /list 30 10
      /list 7 10 dingtalk

---

📊 SUMMARIZE (Simplified)
  /summarize, /总结           Summarize conversations
    
    New: /总结 [topic|all]
    Old: /summarize --topic "Name" or --all
    
    Examples:
      /总结 AI 智能体分类
      /总结 all
      /总结 所有

---

📤 EXPORT (Simplified)
  /export, /导出              Export conversations
    
    New: /导出 [topic] [format] [output_path]
    Old: /export --topic "Name" --format markdown
    
    Examples:
      /导出 AI 智能体分类 markdown
      /导出 all markdown
      /导出 --topic "AI" --format pdf

---

🔄 CHANNEL SWITCH
  /switch, /切换              Channel switch helper
    
    /switch --from dingtalk --to telegram
    /切换 --from 钉钉 --to 微信
    /switch --topic "AI 智能体"

---

🗂️ MANAGE TOPICS
  /topics, /话题              Manage topics
    
    /topics --action list
    /话题 list
    /话题 --action merge --from "A" "B" --to "Merged"

---

⚡ QUICK ACTIONS
  /recent, /最近              Alias for /list
  /quickref, /快速参考        Show quick reference card

---

💡 SYNTAX RULES
---------------

New Syntax (Recommended):
• Space-separated arguments
• No need for --topic, --format etc.
• Natural and concise

Old Syntax (Still supported):
• Traditional --parameter format
• Better for scripts
• More explicit

Both work! Choose your preference.

EOF
}

# Parse command
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

CMD="$1"
shift

# Normalize command
CMD_NAME=$(echo "$CMD" | sed 's/^\///' | tr '[:upper:]' '[:lower:]')

# Fix for Chinese command aliases
case "$CMD_NAME" in
  列表 | 列出) CMD_NAME="list" ;;
  总结 | 摘要) CMD_NAME="summarize" ;;
  导出) CMD_NAME="export" ;;
  搜索 | 查找) CMD_NAME="search" ;;
  加载 | 打开) CMD_NAME="load" ;;
  记录 | 保存) CMD_NAME="record" ;;
  切换 | 渠道) CMD_NAME="switch" ;;
  话题 | 管理) CMD_NAME="topics" ;;
  快速参考 | 参考) CMD_NAME="quickref" ;;
  初始化) CMD_NAME="init" ;;
  帮助) CMD_NAME="help" ;;
  最近) CMD_NAME="recent" ;;
esac

# Route to appropriate script
case "$CMD_NAME" in
  init|初始化)
    bash "$SCRIPT_DIR/init-knowledge.sh" "$@"
    ;;
  
  help|帮助|h|?)
    show_help
    ;;
  
  record|记录|save|保存)
    bash "$SCRIPT_DIR/smart-record.sh" "$@"
    ;;
  
  search|搜索|find|查找)
    bash "$SCRIPT_DIR/search-knowledge.sh" "$@"
    ;;
  
  list|列出|recent|最近)
    bash "$SCRIPT_DIR/list-recent.sh" "$@"
    ;;
  
  load|加载|open|打开)
    bash "$SCRIPT_DIR/load-conversation.sh" "$@"
    ;;
  
  summarize|总结|summary|摘要)
    bash "$SCRIPT_DIR/summarize-conversation.sh" "$@"
    ;;
  
  export|导出)
    bash "$SCRIPT_DIR/export-knowledge.sh" "$@"
    ;;
  
  switch|切换|channel|渠道)
    bash "$SCRIPT_DIR/channel-switch.sh" "$@"
    ;;
  
  topics|话题|manage|管理)
    bash "$SCRIPT_DIR/manage-topics.sh" "$@"
    ;;
  
  quickref|快速参考|ref|参考)
    bash "$SCRIPT_DIR/quickref.sh"
    ;;
  
  *)
    echo "❌ Unknown command: $CMD"
    echo ""
    echo "💡 Use /help or /帮助 to see all available commands"
    exit 1
    ;;
esac
