#!/bin/bash
# Auto Record - Automatically extract topic and summary from conversation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"
TOPICS_DIR="$KNOWLEDGE_DIR/topics"

# Parse arguments
SESSION_CONTENT=""
CHANNEL="dingtalk"
KEYPOINTS=""
MAX_TOPIC_LENGTH=30
MAX_SUMMARY_LENGTH=100

while [[ $# -gt 0 ]]; do
  case $1 in
    --content) SESSION_CONTENT="$2"; shift 2 ;;
    --channel) CHANNEL="$2"; shift 2 ;;
    --keypoints) KEYPOINTS="$2"; shift 2 ;;
    --topic-len) MAX_TOPIC_LENGTH="$2"; shift 2 ;;
    --summary-len) MAX_SUMMARY_LENGTH="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo "🤖 Auto Record - Analyzing conversation content..."
echo ""

# Validate content
if [ -z "$SESSION_CONTENT" ]; then
  echo "❌ Error: --content is required"
  echo ""
  echo "💡 Usage:"
  echo "   /auto-record --content \"conversation text\""
  echo ""
  echo "💡 Or use natural language:"
  echo "   \"把刚才的对话保存一下\" (without topic/summary)"
  exit 1
fi

# Extract first meaningful line (remove markdown headers and empty lines)
FIRST_LINE=$(echo "$SESSION_CONTENT" | grep -v "^#" | grep -v "^$" | head -1)

# Extract summary (first 80 chars)
SUMMARY_CANDIDATE=$(echo "$SESSION_CONTENT" | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-$MAX_SUMMARY_LENGTH)

# Topic extraction using sed (more reliable than bash regex)
EXTRACTED_TOPIC=""

# Pattern 1: "讨论了 XXX" -> XXX
if echo "$FIRST_LINE" | grep -q "讨论"; then
  EXTRACTED_TOPIC=$(echo "$FIRST_LINE" | sed -n 's/.*讨论 [了过]\{0,1\}([A-Za-z0-9\u4e00-\u9fa5]\{2,15\}).*/\1/p' 2>/dev/null || echo "")
fi

# Pattern 2: "关于 XXX" -> XXX
if [ -z "$EXTRACTED_TOPIC" ] && echo "$FIRST_LINE" | grep -q "关于"; then
  EXTRACTED_TOPIC=$(echo "$FIRST_LINE" | sed -n 's/.*关于 ([A-Za-z0-9\u4e00-\u9fa5]\{2,15\}).*/\1/p' 2>/dev/null || echo "")
fi

# Pattern 3: "XXX 的设计/实现/优化" -> XXX
if [ -z "$EXTRACTED_TOPIC" ]; then
  EXTRACTED_TOPIC=$(echo "$FIRST_LINE" | grep -oE '[A-Za-z0-9\u4e00-\u9fa5]{2,12}(的设计 | 的实现 | 的优化 | 的功能 | 的开发)' 2>/dev/null | sed 's/的 [设实优功开].*$//' | head -1 || echo "")
fi

# Fallback: first 4-15 character phrase
if [ -z "$EXTRACTED_TOPIC" ]; then
  EXTRACTED_TOPIC=$(echo "$FIRST_LINE" | grep -oE '[A-Za-z0-9\u4e00-\u9fa5]{4,15}' | head -1 2>/dev/null || echo "")
fi

# Absolute fallback
EXTRACTED_TOPIC="${EXTRACTED_TOPIC:-对话记录}"
EXTRACTED_SUMMARY="${SUMMARY_CANDIDATE:-自动保存的对话内容}..."

echo "📝 Extracted from conversation:"
echo "   Topic: $EXTRACTED_TOPIC"
echo "   Summary: $EXTRACTED_SUMMARY"
echo ""

# Find similar topics
echo "🔍 Finding similar topics..."
echo ""

SIMILAR_TOPICS=()
if [ -f "$INDEX_FILE" ] && command -v jq &> /dev/null; then
  TOPIC_NAMES=$(jq -r '.topics[].name' "$INDEX_FILE" 2>/dev/null)
  
  while IFS= read -r existing_topic; do
    # Check substring match
    if [[ "$existing_topic" == *"$EXTRACTED_TOPIC"* ]] || [[ "$EXTRACTED_TOPIC" == *"$existing_topic"* ]]; then
      SIMILAR_TOPICS+=("$existing_topic")
      continue
    fi
    
    # Check keyword overlap
    IFS=' -_.,，。' read -ra TOPIC_WORDS <<< "$EXTRACTED_TOPIC"
    for word in "${TOPIC_WORDS[@]}"; do
      if [ ${#word} -ge 2 ] && [[ "$existing_topic" == *"$word"* ]]; then
        if [[ ! " ${SIMILAR_TOPICS[@]} " =~ " ${existing_topic} " ]]; then
          SIMILAR_TOPICS+=("$existing_topic")
        fi
        break
      fi
    done
  done <<< "$TOPIC_NAMES"
fi

# Present options
if [ ${#SIMILAR_TOPICS[@]} -gt 0 ]; then
  echo "⚠️  Found ${#SIMILAR_TOPICS[@]} similar topic(s):"
  echo ""
  
  for i in "${!SIMILAR_TOPICS[@]}"; do
    echo "   [$((i+1))] ${SIMILAR_TOPICS[$i]}"
    
    SLUG=$(jq -r --arg name "${SIMILAR_TOPICS[$i]}" '.topics[] | select(.name == $name) | .slug' "$INDEX_FILE" 2>/dev/null)
    if [ -n "$SLUG" ]; then
      ENTRY_COUNT=$(jq -r --arg slug "$SLUG" '.topics[] | select(.slug == $slug) | .entry_count' "$INDEX_FILE" 2>/dev/null)
      LAST_UPDATED=$(jq -r --arg slug "$SLUG" '.topics[] | select(.slug == $slug) | .last_updated | split("T")[0]' "$INDEX_FILE" 2>/dev/null)
      echo "       📊 Entries: $ENTRY_COUNT | Last: $LAST_UPDATED"
    fi
  done
  
  echo ""
  echo "   [N] Create new topic: \"$EXTRACTED_TOPIC\""
  echo ""
  
  # Output structured data
  echo "---CHOICE_START---"
  echo "ACTION: auto_record_conversation"
  echo "EXTRACTED_TOPIC: $EXTRACTED_TOPIC"
  echo "EXTRACTED_SUMMARY: $EXTRACTED_SUMMARY"
  echo "CHANNEL: $CHANNEL"
  echo "SIMILAR_COUNT: ${#SIMILAR_TOPICS[@]}"
  for i in "${!SIMILAR_TOPICS[@]}"; do
    echo "SIMILAR_$((i+1)): ${SIMILAR_TOPICS[$i]}"
  done
  echo "---CHOICE_END---"
  echo ""
  
  echo "💡 Next step:"
  echo "   • To append to existing topic:"
  echo "     \"使用话题 [1]\" or \"/record --topic \\\"${SIMILAR_TOPICS[0]}\\\" --summary \\\"$EXTRACTED_SUMMARY\\\"\""
  echo ""
  echo "   • To create new topic:"
  echo "     \"创建新话题\" or \"/record --topic \\\"$EXTRACTED_TOPIC\\\" --summary \\\"$EXTRACTED_SUMMARY\\\" --new\""
  echo ""
  
else
  echo "✅ No similar topics found."
  echo ""
  echo "📝 Will create new topic: \"$EXTRACTED_TOPIC\""
  echo ""
  
  # Auto-record if no similar topics
  bash "$SCRIPT_DIR/record-conversation.sh" \
    --topic "$EXTRACTED_TOPIC" \
    --summary "$EXTRACTED_SUMMARY" \
    --channel "$CHANNEL" \
    --keypoints "$KEYPOINTS"
  
  echo ""
  echo "✅ Auto record complete!"
fi
