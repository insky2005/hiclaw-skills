#!/bin/bash
# Channel switch helper - load conversation context for multi-channel scenarios

set -e

KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"
TOPICS_DIR="$KNOWLEDGE_DIR/topics"

# Parse arguments
FROM_CHANNEL=""
TO_CHANNEL=""
TOPIC=""
CONTEXT_LINES=20

while [[ $# -gt 0 ]]; do
  case $1 in
    --from) FROM_CHANNEL="$2"; shift 2 ;;
    --to) TO_CHANNEL="$2"; shift 2 ;;
    --topic) TOPIC="$2"; shift 2 ;;
    --lines) CONTEXT_LINES="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo "🔄 Channel Switch Context"
echo "========================"
echo ""

if [ -n "$FROM_CHANNEL" ] && [ -n "$TO_CHANNEL" ]; then
  echo "Switching from: $FROM_CHANNEL → $TO_CHANNEL"
  echo ""
fi

# Check if knowledge base exists
if [ ! -f "$INDEX_FILE" ]; then
  echo "❌ Knowledge base not initialized."
  exit 1
fi

# Show recent context for continuity
echo "📋 Recent Context (for conversation continuity):"
echo ""

# Get last N entries across all channels
COUNT=0
for session_file in $(ls -t "$KNOWLEDGE_DIR/sessions"/*.md 2>/dev/null | head -3); do
  if [ -f "$session_file" ]; then
    FILE_DATE=$(basename "$session_file" .md)
    echo "📅 $FILE_DATE"
    echo ""
    
    # Show last N conversation entries
    grep "^## [0-9]" "$session_file" 2>/dev/null | tail -n "$CONTEXT_LINES" | while read -r line; do
      TIME=$(echo "$line" | sed 's/^## \([0-9:-]*\).*/\1/')
      CHANNEL=$(echo "$line" | sed 's/^## [0-9:-]* (\([^)]*\)).*/\1/')
      TOPIC=$(echo "$line" | sed 's/^## [0-9:-]* ([^)]*) - //')
      
      # Filter by channel if specified
      if [ -n "$FROM_CHANNEL" ] && [[ "$CHANNEL" != *"$FROM_CHANNEL"* ]]; then
        continue
      fi
      
      echo "   • $TIME ($CHANNEL): $TOPIC"
    done
    
    echo ""
    COUNT=$((COUNT + 1))
  fi
done

if [ $COUNT -eq 0 ]; then
  echo "   (No recent conversations found)"
fi

echo ""
echo "---"
echo ""

# If specific topic requested, load it
if [ -n "$TOPIC" ]; then
  echo "📖 Loading topic: $TOPIC"
  echo ""
  
  SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
  TOPIC_FILE="$TOPICS_DIR/$SLUG.md"
  
  if [ -f "$TOPIC_FILE" ]; then
    # Show topic metadata
    if command -v jq &> /dev/null; then
      META=$(jq -r --arg slug "$SLUG" '.topics[] | select(.slug == $slug)' "$INDEX_FILE" 2>/dev/null)
      if [ -n "$META" ]; then
        ENTRY_COUNT=$(echo "$META" | jq -r '.entry_count')
        CHANNELS=$(echo "$META" | jq -r '.channels | join(", ")')
        echo "   Entries: $ENTRY_COUNT | Channels: $CHANNELS"
        echo ""
      fi
    fi
    
    # Show last entry summary
    echo "   Latest:"
    grep -A2 "^## [0-9]" "$TOPIC_FILE" 2>/dev/null | tail -3 | while read -r line; do
      echo "   $line"
    done
    
  else
    echo "   ❌ Topic not found"
  fi
  
  echo ""
fi

echo "---"
echo ""
echo "💡 Usage in new channel:"
echo ""
echo "You can now continue conversations naturally. Reference recent topics:"
echo ""

# Suggest topics to reference
if command -v jq &> /dev/null; then
  jq -r '.topics | sort_by(.last_updated) | reverse | .[0:3] | .[] | "- \(.name) (last: \(.last_updated | split("T")[0]))"' "$INDEX_FILE" 2>/dev/null
else
  echo "- Check list-recent.sh for available topics"
fi

echo ""
echo "📎 Share context file (optional):"
echo "   export-knowledge.sh --topic \"Topic Name\" --format markdown"
