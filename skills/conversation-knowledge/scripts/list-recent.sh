#!/bin/bash
# List recent conversations - Simplified syntax

set -e

KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"
TOPICS_DIR="$KNOWLEDGE_DIR/topics"
SESSIONS_DIR="$KNOWLEDGE_DIR/sessions"

# Parse arguments - support both old and new syntax
LIMIT=10
TOPIC_FILTER=""
CHANNEL_FILTER=""
DAYS=7
USE_OLD_SYNTAX=false

# Check if using old syntax
if [[ "$*" == *"--days"* ]] || [[ "$*" == *"--limit"* ]] || [[ "$*" == *"--channel"* ]]; then
  USE_OLD_SYNTAX=true
fi

if [ "$USE_OLD_SYNTAX" = true ]; then
  # Old syntax
  while [[ $# -gt 0 ]]; do
    case $1 in
      --limit) LIMIT="$2"; shift 2 ;;
      --topic) TOPIC_FILTER="$2"; shift 2 ;;
      --channel) CHANNEL_FILTER="$2"; shift 2 ;;
      --days) DAYS="$2"; shift 2 ;;
      *) echo "Unknown option: $1"; exit 1 ;;
    esac
  done
else
  # New syntax: [days] [limit] [channel]
  if [ $# -ge 1 ]; then
    if [[ "$1" =~ ^[0-9]+$ ]]; then
      DAYS="$1"
      shift
    fi
  fi
  if [ $# -ge 1 ]; then
    if [[ "$1" =~ ^[0-9]+$ ]]; then
      LIMIT="$1"
      shift
    fi
  fi
  if [ $# -ge 1 ]; then
    CHANNEL_FILTER="$1"
  fi
fi

echo "📋 Recent Conversations"
echo "======================"
echo ""

# Check if knowledge base exists
if [ ! -f "$INDEX_FILE" ]; then
  echo "❌ Knowledge base not initialized. Run /init first."
  exit 1
fi

# List by topics
if [ -z "$CHANNEL_FILTER" ]; then
  echo "📌 By Topic (Last $DAYS days):"
  echo ""
  
  COUNT=0
  if command -v jq &> /dev/null; then
    jq -r --argjson limit "$LIMIT" '
      .topics | sort_by(.last_updated) | reverse | .[0:$limit] | .[] |
      "📄 \(.name)\n   Last: \(.last_updated | split("T")[0])\n   Entries: \(.entry_count)\n   Channels: \(.channels | join(", "))\n"
    ' "$INDEX_FILE"
  else
    for topic_file in $(ls -t "$TOPICS_DIR"/*.md 2>/dev/null | head -n "$LIMIT"); do
      if [ -f "$topic_file" ]; then
        TOPIC_NAME=$(head -1 "$topic_file" | sed 's/^# //')
        ENTRY_COUNT=$(grep -c "^## " "$topic_file" 2>/dev/null || echo "0")
        MOD_TIME=$(stat -c %y "$topic_file" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
        echo "📄 $TOPIC_NAME"
        echo "   Last: $MOD_TIME"
        echo "   Entries: ~$ENTRY_COUNT"
        echo ""
        COUNT=$((COUNT + 1))
      fi
    done
  fi
  
  if [ $COUNT -eq 0 ]; then
    echo "   (No topics found)"
  fi
  
  echo ""
fi

# List by session files
echo "📅 By Date (Last $DAYS days):"
echo ""

TODAY_EPOCH=$(date +%s)
DAYS_AGO_EPOCH=$((TODAY_EPOCH - DAYS * 86400))

COUNT=0
for session_file in $(ls -t "$SESSIONS_DIR"/*.md 2>/dev/null); do
  if [ -f "$session_file" ]; then
    FILE_DATE=$(basename "$session_file" .md)
    FILE_EPOCH=$(date -d "$FILE_DATE" +%s 2>/dev/null || echo "0")
    
    if [ "$FILE_EPOCH" -ge "$DAYS_AGO_EPOCH" ]; then
      ENTRY_COUNT=$(grep -c "^## " "$session_file" 2>/dev/null || echo "0")
      
      if [ "$ENTRY_COUNT" -gt 1 ]; then
        echo "📅 $FILE_DATE"
        
        grep "^## " "$session_file" 2>/dev/null | tail -n 5 | while read -r line; do
          TIME=$(echo "$line" | sed 's/^## \([0-9:-]*\).*/\1/')
          CHANNEL=$(echo "$line" | sed 's/^## [0-9:-]* (\([^)]*\)).*/\1/')
          TOPIC=$(echo "$line" | sed 's/^## [0-9:-]* ([^)]*) - //')
          echo "   • $TIME ($CHANNEL): $TOPIC"
        done
        
        echo ""
        COUNT=$((COUNT + 1))
      fi
    fi
  fi
done

if [ $COUNT -eq 0 ]; then
  echo "   (No recent sessions found)"
fi

echo ""
echo "💡 Tips:"
echo "   - Load full topic:    /加载 Topic Name"
echo "   - Search:             /搜索 keyword"
echo "   - Export:             /导出 Topic Name markdown"
echo "   - More history:       /list 30  (last 30 days)"
