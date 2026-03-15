#!/bin/bash
# Load a specific conversation topic - Simplified syntax

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"
TOPICS_DIR="$KNOWLEDGE_DIR/topics"

# Parse arguments - support both old and new syntax
TOPIC=""
FORMAT="full"
USE_OLD_SYNTAX=false

# Check if using old syntax (--topic)
if [[ "$*" == *"--topic"* ]]; then
  USE_OLD_SYNTAX=true
fi

if [ "$USE_OLD_SYNTAX" = true ]; then
  # Old syntax: --topic "Name" --format full
  while [[ $# -gt 0 ]]; do
    case $1 in
      --topic) TOPIC="$2"; shift 2 ;;
      --format) FORMAT="$2"; shift 2 ;;
      *) echo "Unknown option: $1"; exit 1 ;;
    esac
  done
else
  # New syntax: just space-separated words
  # First argument is topic name, optional second is format
  if [ $# -ge 1 ]; then
    # Join all arguments as topic name (supports spaces in topic)
    TOPIC="$*"
    
    # Check if last word is a format specifier
    LAST_WORD="${!#}"
    if [[ "$LAST_WORD" == "full" ]] || [[ "$LAST_WORD" == "summary" ]] || [[ "$LAST_WORD" == "timeline" ]]; then
      FORMAT="$LAST_WORD"
      # Remove last word from topic
      TOPIC="${@:1:$#-1}"
    fi
  fi
fi

if [ -z "$TOPIC" ]; then
  echo "📖 Load Conversation"
  echo ""
  echo "❌ Error: Topic name is required"
  echo ""
  echo "💡 Usage (New - Simplified):"
  echo "   /load AI 智能体分类"
  echo "   /加载 AI 智能体分类 full"
  echo "   /load Project Planning summary"
  echo ""
  echo "💡 Usage (Old - Still supported):"
  echo "   /load --topic \"AI 智能体分类\" --format full"
  echo "   /加载 --topic \"Project\" --format summary"
  exit 1
fi

echo "📖 Loading conversation: $TOPIC"
echo ""

# Generate slug from topic name
SLUG=""
if [ -f "$INDEX_FILE" ] && command -v jq &> /dev/null; then
  SLUG=$(jq -r --arg name "$TOPIC" '.topics[] | select(.name == $name) | .slug' "$INDEX_FILE" 2>/dev/null)
fi

# Fallback: generate slug
if [ -z "$SLUG" ] || [ "$SLUG" = "null" ]; then
  SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
fi

TOPIC_FILE="$TOPICS_DIR/$SLUG.md"

# Check if topic exists
if [ ! -f "$TOPIC_FILE" ]; then
  echo "❌ Topic not found: $TOPIC"
  echo ""
  echo "💡 Available topics:"
  
  if command -v jq &> /dev/null && [ -f "$INDEX_FILE" ]; then
    jq -r '.topics[].name' "$INDEX_FILE" 2>/dev/null | while read -r name; do
      echo "   - $name"
    done
  else
    for topic_file in "$TOPICS_DIR"/*.md; do
      if [ -f "$topic_file" ]; then
        name=$(head -1 "$topic_file" | sed 's/^# //')
        echo "   - $name"
      fi
    done
  fi
  
  exit 1
fi

# Get topic metadata
if command -v jq &> /dev/null && [ -f "$INDEX_FILE" ]; then
  META=$(jq -r --arg slug "$SLUG" '.topics[] | select(.slug == $slug)' "$INDEX_FILE" 2>/dev/null)
  if [ -n "$META" ]; then
    ENTRY_COUNT=$(echo "$META" | jq -r '.entry_count')
    FIRST_RECORDED=$(echo "$META" | jq -r '.first_recorded' | cut -d'T' -f1)
    LAST_UPDATED=$(echo "$META" | jq -r '.last_updated' | cut -d'T' -f1)
    CHANNELS=$(echo "$META" | jq -r '.channels | join(", ")')
    
    echo "📊 Topic Metadata:"
    echo "   Entries: $ENTRY_COUNT"
    echo "   First: $FIRST_RECORDED"
    echo "   Last: $LAST_UPDATED"
    echo "   Channels: $CHANNELS"
    echo ""
    echo "---"
    echo ""
  fi
fi

# Output based on format
case $FORMAT in
  full)
    echo "📄 Full Conversation Log:"
    echo ""
    cat "$TOPIC_FILE"
    ;;
    
  summary)
    echo "📝 Summary:"
    echo ""
    
    # Extract all summaries
    grep -A1 "^\*\*摘要\*\*:" "$TOPIC_FILE" 2>/dev/null | while read -r line; do
      if [[ "$line" == "**摘要**:"* ]]; then
        continue
      fi
      if [ -n "$line" ]; then
        echo "• $line"
      fi
    done
    
    echo ""
    echo "---"
    echo ""
    echo "💡 Use 'full' format to see complete conversation details"
    echo "   Example: /加载 $TOPIC full"
    ;;
    
  timeline)
    echo "📅 Timeline:"
    echo ""
    
    # Extract all timestamps and channels
    grep "^## [0-9]" "$TOPIC_FILE" 2>/dev/null | while read -r line; do
      TIME=$(echo "$line" | sed 's/^## \([0-9:-]*\).*/\1/')
      CHANNEL=$(echo "$line" | sed 's/^## [0-9:-]* (\([^)]*\)).*/\1/')
      echo "📍 $TIME ($CHANNEL)"
    done
    
    echo ""
    echo "---"
    echo ""
    echo "💡 Use 'full' format to see complete conversation details"
    ;;
    
  *)
    echo "❌ Unknown format: $FORMAT"
    echo "   Valid formats: full, summary, timeline"
    exit 1
    ;;
esac

echo ""

# Set context for smart recording
bash "$SCRIPT_DIR/context-tracker.sh" set-topic "$TOPIC" 2>/dev/null || true

echo "💡 Next actions:"
echo "   - Export:     /导出 $TOPIC markdown"
echo "   - Search:     /搜索 --query \"keyword\" --topic \"$TOPIC\""
echo "   - Summarize:  /总结 $TOPIC"
echo "   - Record:     /记录 --summary \"...\" (will append to this topic)"
