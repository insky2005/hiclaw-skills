#!/bin/bash
# Export conversation knowledge - Simplified

set -e

KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
TOPICS_DIR="$KNOWLEDGE_DIR/topics"
SESSIONS_DIR="$KNOWLEDGE_DIR/sessions"
EXPORTS_DIR="$KNOWLEDGE_DIR/exports"

# Simple parsing: first arg is topic, second is format
TOPIC="$1"
FORMAT="${2:-markdown}"

if [ -z "$TOPIC" ] || [[ "$TOPIC" == "--"* ]]; then
  echo "📤 Export Conversations"
  echo ""
  echo "💡 Usage:"
  echo "   /导出 Topic Name [format]"
  echo "   /导出 AI 智能体分类 markdown"
  echo "   /导出 all html"
  echo ""
  echo "   Old syntax still works:"
  echo "   /export --topic \"Name\" --format markdown"
  exit 1
fi

mkdir -p "$EXPORTS_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ "$TOPIC" = "all" ] || [ "$TOPIC" = "所有" ]; then
  # Export all sessions
  OUTPUT_FILE="$EXPORTS_DIR/all-${TIMESTAMP}.md"
  echo "📤 Exporting all conversations..."
  
  cat > "$OUTPUT_FILE" << EOF
# All Conversations Export

Generated: $(date -Iseconds)

---

EOF
  
  for session_file in "$SESSIONS_DIR"/*.md; do
    if [ -f "$session_file" ]; then
      cat "$session_file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    fi
  done
  
else
  # Export specific topic
  SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
  TOPIC_FILE="$TOPICS_DIR/$SLUG.md"
  
  if [ ! -f "$TOPIC_FILE" ]; then
    echo "❌ Topic not found: $TOPIC"
    echo ""
    echo "💡 Available topics:"
    for f in "$TOPICS_DIR"/*.md; do
      if [ -f "$f" ]; then
        echo "   - $(head -1 "$f" | sed 's/^# //')"
      fi
    done
    exit 1
  fi
  
  OUTPUT_FILE="$EXPORTS_DIR/topic-${SLUG}-${TIMESTAMP}.md"
  echo "📤 Exporting topic: $TOPIC"
  cp "$TOPIC_FILE" "$OUTPUT_FILE"
fi

echo ""
echo "✅ Export completed!"
echo "   File: $OUTPUT_FILE"
echo "   Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo ""

# DingTalk tag
echo "📎 DingTalk sharing:"
echo "[DINGTALK_FILE]{\"path\":\"$OUTPUT_FILE\",\"fileName\":\"$(basename "$OUTPUT_FILE")\",\"fileType\":\"md\"}[/DINGTALK_FILE]"
