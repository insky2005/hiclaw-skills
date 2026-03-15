#!/bin/bash
# Smart Record - Auto-extract topic and find similar topics
# Now with context awareness

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"
TOPICS_DIR="$KNOWLEDGE_DIR/topics"
CONTEXT_FILE="$KNOWLEDGE_DIR/.context.json"

# Parse arguments
AUTO_TOPIC=""
AUTO_SUMMARY=""
CHANNEL="dingtalk"
KEYPOINTS=""
FORCE_NEW=false
USE_CONTEXT=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --topic) AUTO_TOPIC="$2"; shift 2 ;;
    --summary) AUTO_SUMMARY="$2"; shift 2 ;;
    --channel) CHANNEL="$2"; shift 2 ;;
    --keypoints) KEYPOINTS="$2"; shift 2 ;;
    --new) FORCE_NEW=true; shift ;;
    --use-context) USE_CONTEXT=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo "🤖 Smart Record - Analyzing..."
echo ""

# Step 1: Check for active context (recently loaded topic)
CONTEXT_TOPIC=""
if [ "$FORCE_NEW" = false ] && [ -f "$CONTEXT_FILE" ]; then
  CONTEXT_TOPIC=$(bash "$SCRIPT_DIR/context-tracker.sh" get-topic 2>/dev/null || echo "")
  
  if [ -n "$CONTEXT_TOPIC" ] && [ -z "$AUTO_TOPIC" ]; then
    echo "📍 Found active context: $CONTEXT_TOPIC"
    echo ""
    AUTO_TOPIC="$CONTEXT_TOPIC"
  fi
fi

# Step 2: Validate required parameters
if [ -z "$AUTO_TOPIC" ] || [ -z "$AUTO_SUMMARY" ]; then
  echo "❌ Error: --topic and --summary are required"
  echo ""
  echo "💡 Usage:"
  echo "   /record --topic \"Topic Name\" --summary \"Brief summary\""
  echo "   /记录 --topic \"话题名\" --summary \"摘要\""
  echo ""
  echo "💡 Or use natural language:"
  echo "   \"把刚才的对话保存一下，主题是 XXX\""
  exit 1
fi

# Step 3: Find similar topics (only if not forcing new and not from context)
SIMILAR_TOPICS=()
if [ "$FORCE_NEW" = false ] && [ -z "$CONTEXT_TOPIC" ] && [ -f "$INDEX_FILE" ] && command -v jq &> /dev/null; then
  echo "🔍 Finding similar topics for: \"$AUTO_TOPIC\""
  echo ""
  
  TOPIC_NAMES=$(jq -r '.topics[].name' "$INDEX_FILE" 2>/dev/null)
  
  while IFS= read -r existing_topic; do
    if [[ "$existing_topic" == *"$AUTO_TOPIC"* ]] || [[ "$AUTO_TOPIC" == *"$existing_topic"* ]]; then
      SIMILAR_TOPICS+=("$existing_topic")
      continue
    fi
    
    IFS=' -_.,，。' read -ra TOPIC_WORDS <<< "$AUTO_TOPIC"
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

# Step 4: Present options
if [ ${#SIMILAR_TOPICS[@]} -gt 0 ]; then
  echo "⚠️  Found ${#SIMILAR_TOPICS[@]} similar topic(s):"
  echo ""
  
  for i in "${!SIMILAR_TOPICS[@]}"; do
    echo "   [$((i+1))] ${SIMILAR_TOPICS[$i]}"
    
    SLUG=$(jq -r --arg name "${SIMILAR_TOPICS[$i]}" '.topics[] | select(.name == $name) | .slug' "$INDEX_FILE" 2>/dev/null)
    if [ -n "$SLUG" ]; then
      ENTRY_COUNT=$(jq -r --arg slug "$SLUG" '.topics[] | select(.slug == $slug) | .entry_count' "$INDEX_FILE" 2>/dev/null)
      LAST_UPDATED=$(jq -r --arg slug "$SLUG" '.topics[] | select(.slug == $slug) | .last_updated | split("T")[0]' "$INDEX_FILE" 2>/dev/null)
      CHANNELS=$(jq -r --arg slug "$SLUG" '.topics[] | select(.slug == $slug) | .channels | join(", ")' "$INDEX_FILE" 2>/dev/null)
      echo "       📊 Entries: $ENTRY_COUNT | Last: $LAST_UPDATED | Channels: $CHANNELS"
    fi
  done
  
  echo ""
  echo "   [N] Create new topic: \"$AUTO_TOPIC\""
  echo ""
  
  echo "---CHOICE_START---"
  echo "ACTION: record_conversation"
  echo "TOPIC: $AUTO_TOPIC"
  echo "SUMMARY: $AUTO_SUMMARY"
  echo "CHANNEL: $CHANNEL"
  echo "KEYPOINTS: $KEYPOINTS"
  echo "SIMILAR_COUNT: ${#SIMILAR_TOPICS[@]}"
  for i in "${!SIMILAR_TOPICS[@]}"; do
    echo "SIMILAR_$((i+1)): ${SIMILAR_TOPICS[$i]}"
  done
  echo "---CHOICE_END---"
  echo ""
  
  echo "💡 Next step:"
  echo "   • To append to existing topic, say:"
  echo "     \"使用话题 [1]\" or \"/record --topic \\\"${SIMILAR_TOPICS[0]}\\\" --summary \\\"$AUTO_SUMMARY\\\"\""
  echo ""
  echo "   • To create new topic, say:"
  echo "     \"创建新话题\" or \"/record --topic \\\"$AUTO_TOPIC\\\" --summary \\\"$AUTO_SUMMARY\\\" --new\""
  echo ""
  
else
  if [ -n "$CONTEXT_TOPIC" ]; then
    echo "✅ Recording to active context topic: \"$AUTO_TOPIC\""
  else
    echo "✅ No similar topics found."
    echo ""
    echo "📝 Will create new topic: \"$AUTO_TOPIC\""
  fi
  echo ""
  
  # Auto-record
  bash "$SCRIPT_DIR/record-conversation.sh" \
    --topic "$AUTO_TOPIC" \
    --summary "$AUTO_SUMMARY" \
    --channel "$CHANNEL" \
    --keypoints "$KEYPOINTS"
  
  echo ""
  echo "✅ Smart record complete!"
  
  # Clear context after successful record
  bash "$SCRIPT_DIR/context-tracker.sh" clear 2>/dev/null || true
fi
