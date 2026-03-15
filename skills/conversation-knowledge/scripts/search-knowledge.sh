#!/bin/bash
# Search conversation knowledge base - Simplified syntax

set -e

KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"
TOPICS_DIR="$KNOWLEDGE_DIR/topics"
SESSIONS_DIR="$KNOWLEDGE_DIR/sessions"

# Parse arguments - support both old and new syntax
QUERY=""
TOPIC_FILTER=""
SINCE=""
LIMIT=10
USE_OLD_SYNTAX=false

# Check if using old syntax
if [[ "$*" == *"--query"* ]] || [[ "$*" == *"--topic"* ]]; then
  USE_OLD_SYNTAX=true
fi

if [ "$USE_OLD_SYNTAX" = true ]; then
  # Old syntax
  while [[ $# -gt 0 ]]; do
    case $1 in
      --query) QUERY="$2"; shift 2 ;;
      --topic) TOPIC_FILTER="$2"; shift 2 ;;
      --since) SINCE="$2"; shift 2 ;;
      --limit) LIMIT="$2"; shift 2 ;;
      *) echo "Unknown option: $1"; exit 1 ;;
    esac
  done
else
  # New syntax: first word is query, optional second is topic filter
  if [ $# -ge 1 ]; then
    QUERY="$1"
    shift
    
    if [ $# -ge 1 ]; then
      # Check if it's a number (limit) or topic filter
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        LIMIT="$1"
      else
        # Rest is topic filter
        TOPIC_FILTER="$*"
      fi
    fi
  fi
fi

if [ -z "$QUERY" ] && [ -z "$TOPIC_FILTER" ]; then
  echo "🔍 Search Conversations"
  echo ""
  echo "❌ Error: Search query or topic filter is required"
  echo ""
  echo "💡 Usage (New - Simplified):"
  echo "   /搜索 智能体"
  echo "   /搜索 智能体 AI 智能体分类"
  echo "   /搜索 AI 10  (query, limit)"
  echo ""
  echo "💡 Usage (Old - Still supported):"
  echo "   /search --query \"智能体\" --topic \"AI 分类\""
  echo "   /搜索 --query \"AI\" --limit 10"
  exit 1
fi

echo "🔍 Searching knowledge base..."
if [ -n "$QUERY" ]; then
  echo "   Query: $QUERY"
fi
if [ -n "$TOPIC_FILTER" ]; then
  echo "   Topic filter: $TOPIC_FILTER"
fi
if [ -n "$SINCE" ]; then
  echo "   Since: $SINCE"
fi
echo ""

# Search in topic files
if [ -n "$TOPIC_FILTER" ]; then
  # Exact topic match
  SLUG=$(echo "$TOPIC_FILTER" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g' | sed 's/--*/-/g')
  TOPIC_FILE="$TOPICS_DIR/$SLUG.md"
  if [ -f "$TOPIC_FILE" ]; then
    echo "📄 Found topic: $TOPIC_FILTER"
    echo ""
    head -50 "$TOPIC_FILE"
    echo ""
  else
    echo "❌ Topic not found: $TOPIC_FILTER"
    echo "   Try: /话题 list"
  fi
elif [ -n "$QUERY" ]; then
  # Full-text search
  echo "📊 Search Results:"
  echo "================"
  echo ""
  
  COUNT=0
  for topic_file in "$TOPICS_DIR"/*.md; do
    if [ -f "$topic_file" ] && grep -qi "$QUERY" "$topic_file" 2>/dev/null; then
      COUNT=$((COUNT + 1))
      if [ $COUNT -le $LIMIT ]; then
        TOPIC_NAME=$(head -1 "$topic_file" | sed 's/^# //')
        MATCHES=$(grep -n -i "$QUERY" "$topic_file" | head -3)
        echo "📌 $TOPIC_NAME"
        echo "   File: $topic_file"
        echo "   Matches:"
        echo "$MATCHES" | while read -r line; do
          LINE_NUM=$(echo "$line" | cut -d: -f1)
          CONTENT=$(echo "$line" | cut -d: -f2- | head -c 100)
          echo "     Line $LINE_NUM: ...$CONTENT..."
        done
        echo ""
      fi
    fi
  done
  
  if [ $COUNT -eq 0 ]; then
    echo "❌ No results found for: $QUERY"
    echo ""
    echo "💡 Tips:"
    echo "   - Try different keywords"
    echo "   - Use /话题 list to browse all topics"
  elif [ $COUNT -gt $LIMIT ]; then
    echo "... and $((COUNT - LIMIT)) more results"
  fi
  
  echo ""
  echo "Total matches: $COUNT"
fi
