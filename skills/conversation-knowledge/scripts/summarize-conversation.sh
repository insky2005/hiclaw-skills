#!/bin/bash
# Summarize conversation topics - Simplified syntax

set -e

KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"
TOPICS_DIR="$KNOWLEDGE_DIR/topics"
EXPORTS_DIR="$KNOWLEDGE_DIR/exports"

# Parse arguments - support both old and new syntax
TOPIC=""
SUMMARIZE_ALL=false
OUTPUT_PATH=""
OUTPUT_FORMAT="text"
INCLUDE_KEYPOINTS=true
INCLUDE_TIMELINE=false
USE_OLD_SYNTAX=false

# Check if using old syntax
if [[ "$*" == *"--topic"* ]] || [[ "$*" == *"--all"* ]] || [[ "$*" == *"--output"* ]]; then
  USE_OLD_SYNTAX=true
fi

if [ "$USE_OLD_SYNTAX" = true ]; then
  # Old syntax
  while [[ $# -gt 0 ]]; do
    case $1 in
      --topic) TOPIC="$2"; shift 2 ;;
      --all) SUMMARIZE_ALL=true; shift ;;
      --output) OUTPUT_PATH="$2"; shift 2 ;;
      --format) OUTPUT_FORMAT="$2"; shift 2 ;;
      --no-keypoints) INCLUDE_KEYPOINTS=false; shift ;;
      --timeline) INCLUDE_TIMELINE=true; shift ;;
      *) echo "Unknown option: $1"; exit 1 ;;
    esac
  done
else
  # New syntax: first argument is topic, "all" means all topics
  if [ $# -ge 1 ]; then
    FIRST_ARG="$1"
    shift
    
    if [ "$FIRST_ARG" = "all" ] || [ "$FIRST_ARG" = "所有" ]; then
      SUMMARIZE_ALL=true
    else
      TOPIC="$FIRST_ARG"
    fi
    
    # Check for output path
    if [ $# -ge 1 ] && [[ "$1" == /* ]]; then
      OUTPUT_PATH="$1"
      shift
    fi
  fi
fi

mkdir -p "$EXPORTS_DIR"

# Generate filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
if [ -n "$TOPIC" ]; then
  SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
  FILENAME="topic-${SLUG}-${TIMESTAMP}"
else
  FILENAME="conversations-${TIMESTAMP}"
fi

# Determine output file
if [ -n "$OUTPUT_PATH" ]; then
  OUTPUT_FILE="$OUTPUT_PATH"
else
  OUTPUT_FILE="$EXPORTS_DIR/summary-${FILENAME}.md"
fi

echo "📊 Summarizing conversations..."
if [ -n "$TOPIC" ]; then
  echo "   Topic: $TOPIC"
elif [ "$SUMMARIZE_ALL" = true ]; then
  echo "   Scope: All topics"
fi
echo "   Output: $OUTPUT_FILE"
echo ""

# Generate summary
cat > "$OUTPUT_FILE" << EOF
# Conversation Summary

**Generated**: $(date -Iseconds)

---

EOF

if [ -n "$TOPIC" ]; then
  # Summarize specific topic
  SLUG=""
  if command -v jq &> /dev/null && [ -f "$INDEX_FILE" ]; then
    SLUG=$(jq -r --arg name "$TOPIC" '.topics[] | select(.name == $name) | .slug' "$INDEX_FILE" 2>/dev/null)
  fi
  
  if [ -z "$SLUG" ]; then
    SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
  fi
  
  TOPIC_FILE="$TOPICS_DIR/$SLUG.md"
  
  if [ ! -f "$TOPIC_FILE" ]; then
    echo "❌ Topic not found: $TOPIC"
    echo "   Generated slug: $SLUG"
    echo ""
    echo "💡 Available topics:"
    if command -v jq &> /dev/null; then
      jq -r '.topics[].name' "$INDEX_FILE" 2>/dev/null | sed 's/^/   - /'
    fi
    exit 1
  fi
  
  echo "📄 Summarizing: $TOPIC"
  
  TOPIC_NAME=$(head -1 "$TOPIC_FILE" | sed 's/^# //')
  ENTRY_COUNT=$(grep -c "^## " "$TOPIC_FILE" 2>/dev/null || echo "0")
  
  cat >> "$OUTPUT_FILE" << EOF
## $TOPIC_NAME

**Total Entries**: $ENTRY_COUNT

EOF
  
  if [ "$INCLUDE_KEYPOINTS" = true ]; then
    echo "**Key Points**:" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    IN_KEYPOINTS=false
    while IFS= read -r line; do
      if [[ "$line" == "**关键点**:"* ]] || [[ "$line" == "**Key Points**:"* ]]; then
        IN_KEYPOINTS=true
        continue
      fi
      if [[ "$line" == "## "* ]] && [ "$IN_KEYPOINTS" = true ]; then
        IN_KEYPOINTS=false
      fi
      if [ "$IN_KEYPOINTS" = true ] && [ -n "$line" ]; then
        echo "$line" >> "$OUTPUT_FILE"
      fi
    done < "$TOPIC_FILE"
    
    echo "" >> "$OUTPUT_FILE"
  fi
  
  echo "**Conversation Summaries**:" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  
  grep -B1 "^\*\*摘要\*\*:" "$TOPIC_FILE" 2>/dev/null | while IFS= read -r line; do
    if [[ "$line" == "## "* ]]; then
      HEADER=$(echo "$line" | sed 's/^## //')
      echo "### $HEADER" >> "$OUTPUT_FILE"
    elif [[ "$line" == "**摘要**:"* ]]; then
      SUMMARY=$(echo "$line" | sed 's/\*\*摘要\*\*: //')
      echo "" >> "$OUTPUT_FILE"
      echo "$SUMMARY" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    fi
  done
  
else
  # Summarize all topics
  echo "📄 Summarizing all topics..."
  
  if command -v jq &> /dev/null && [ -f "$INDEX_FILE" ]; then
    TOTAL_TOPICS=$(jq '.topics | length' "$INDEX_FILE")
    TOTAL_ENTRIES=$(jq '.total_entries' "$INDEX_FILE")
    LAST_UPDATED=$(jq -r '.updated_at' "$INDEX_FILE" | cut -d'T' -f1)
    
    cat >> "$OUTPUT_FILE" << EOF
## Overview

- **Total Topics**: $TOTAL_TOPICS
- **Total Entries**: $TOTAL_ENTRIES
- **Last Updated**: $LAST_UPDATED

---

EOF
    
    echo "## Topics" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    jq -r '.topics[] | "- **\(.name)**: \(.entry_count) entries (last: \(.last_updated | split("T")[0]))"' "$INDEX_FILE" >> "$OUTPUT_FILE"
    
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "## Detailed Summaries" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    jq -r '.topics[].slug' "$INDEX_FILE" | while read -r slug; do
      TOPIC_FILE="$TOPICS_DIR/$slug.md"
      if [ -f "$TOPIC_FILE" ]; then
        TOPIC_NAME=$(head -1 "$TOPIC_FILE" | sed 's/^# //')
        ENTRY_COUNT=$(grep -c "^## " "$TOPIC_FILE" 2>/dev/null || echo "0")
        
        echo "### $TOPIC_NAME" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "*$ENTRY_COUNT conversation entries*" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        FIRST_SUMMARY=$(grep -A1 "^\*\*摘要\*\*:" "$TOPIC_FILE" 2>/dev/null | tail -1 | head -c 200)
        if [ -n "$FIRST_SUMMARY" ]; then
          echo "> $FIRST_SUMMARY..." >> "$OUTPUT_FILE"
          echo "" >> "$OUTPUT_FILE"
        fi
      fi
    done
  else
    echo "⚠️  jq not found or index missing, generating basic summary..."
    
    echo "## Topics" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    for topic_file in "$TOPICS_DIR"/*.md; do
      if [ -f "$topic_file" ]; then
        TOPIC_NAME=$(head -1 "$topic_file" | sed 's/^# //')
        ENTRY_COUNT=$(grep -c "^## " "$topic_file" 2>/dev/null || echo "0")
        echo "- **$TOPIC_NAME**: $ENTRY_COUNT entries" >> "$OUTPUT_FILE"
      fi
    done
  fi
fi

echo ""
echo "✅ Summary generated!"
echo "   File: $OUTPUT_FILE"
echo "   Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo ""

# Display preview
echo "📋 Preview:"
echo "=========="
echo ""
head -50 "$OUTPUT_FILE"

# For DingTalk sharing
if [[ "$OUTPUT_FILE" == *.md ]]; then
  echo ""
  echo "📎 DingTalk sharing tag:"
  echo "[DINGTALK_FILE]{\"path\":\"$OUTPUT_FILE\",\"fileName\":\"$(basename "$OUTPUT_FILE")\",\"fileType\":\"md\"}[/DINGTALK_FILE]"
fi
