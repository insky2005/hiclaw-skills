#!/bin/bash
# Manage topics in conversation knowledge base

set -e

KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"
TOPICS_DIR="$KNOWLEDGE_DIR/topics"

# Parse arguments
ACTION=""
FROM_TOPICS=()
TO_TOPIC=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --action) ACTION="$2"; shift 2 ;;
    --from) shift; while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do FROM_TOPICS+=("$1"); shift; done ;;
    --to) TO_TOPIC="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

case $ACTION in
  list)
    echo "📚 All Topics:"
    echo "============="
    echo ""
    
    if [ ! -f "$INDEX_FILE" ]; then
      echo "❌ Knowledge base not initialized. Run init-knowledge.sh first."
      exit 1
    fi
    
    if command -v jq &> /dev/null; then
      jq -r '.topics[] | "📌 \(.name)\n   Slug: \(.slug)\n   Entries: \(.entry_count)\n   Channels: \(.channels | join(", "))\n   Last updated: \(.last_updated)\n"' "$INDEX_FILE"
    else
      # Fallback without jq
      for topic_file in "$TOPICS_DIR"/*.md; do
        if [ -f "$topic_file" ]; then
          TOPIC_NAME=$(head -1 "$topic_file" | sed 's/^# //')
          ENTRY_COUNT=$(grep -c "^## " "$topic_file" 2>/dev/null || echo "0")
          echo "📌 $TOPIC_NAME"
          echo "   File: $topic_file"
          echo "   Entries: ~$ENTRY_COUNT"
          echo ""
        fi
      done
    fi
    ;;
    
  merge)
    if [ ${#FROM_TOPICS[@]} -lt 2 ] || [ -z "$TO_TOPIC" ]; then
      echo "❌ Error: --from requires at least 2 topics, --to requires target name"
      echo "   Example: --from \"topic-a\" \"topic-b\" --to \"merged-topic\""
      exit 1
    fi
    
    echo "🔀 Merging topics..."
    echo "   From: ${FROM_TOPICS[*]}"
    echo "   To: $TO_TOPIC"
    echo ""
    
    TO_SLUG=$(echo "$TO_TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
    TO_FILE="$TOPICS_DIR/$TO_SLUG.md"
    
    # Create target file
    cat > "$TO_FILE" << EOF
# $TO_TOPIC

<!-- Merged from: ${FROM_TOPICS[*]} -->
<!-- Merged at: $(date -Iseconds) -->

EOF
    
    # Append content from source files
    for from_topic in "${FROM_TOPICS[@]}"; do
      FROM_SLUG=$(echo "$from_topic" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
      FROM_FILE="$TOPICS_DIR/$FROM_SLUG.md"
      
      if [ -f "$FROM_FILE" ]; then
        echo "   Merging: $from_topic"
        echo "" >> "$TO_FILE"
        echo "---" >> "$TO_FILE"
        echo "" >> "$TO_FILE"
        # Skip the first line (title) and append rest
        tail -n +2 "$FROM_FILE" >> "$TO_FILE"
      else
        echo "   ⚠️  Not found: $from_topic"
      fi
    done
    
    echo ""
    echo "✅ Merge completed: $TO_FILE"
    echo ""
    echo "⚠️  Note: Original topic files are preserved. Delete manually if needed."
    ;;
    
  rename)
    if [ -z "$FROM_TOPICS[0]" ] || [ -z "$TO_TOPIC" ]; then
      echo "❌ Error: --from and --to are required"
      exit 1
    fi
    
    FROM_TOPIC="${FROM_TOPICS[0]}"
    FROM_SLUG=$(echo "$FROM_TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
    TO_SLUG=$(echo "$TO_TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
    
    FROM_FILE="$TOPICS_DIR/$FROM_SLUG.md"
    TO_FILE="$TOPICS_DIR/$TO_SLUG.md"
    
    if [ ! -f "$FROM_FILE" ]; then
      echo "❌ Topic not found: $FROM_TOPIC"
      exit 1
    fi
    
    if [ -f "$TO_FILE" ]; then
      echo "❌ Target topic already exists: $TO_TOPIC"
      exit 1
    fi
    
    echo "✏️  Renaming topic..."
    echo "   From: $FROM_TOPIC"
    echo "   To: $TO_TOPIC"
    
    # Update title in file
    sed "1s/.*/# $TO_TOPIC/" "$FROM_FILE" > "$TO_FILE"
    rm "$FROM_FILE"
    
    echo ""
    echo "✅ Rename completed!"
    ;;
    
  delete)
    if [ -z "$FROM_TOPICS[0]" ]; then
      echo "❌ Error: --from is required (topic to delete)"
      exit 1
    fi
    
    FROM_TOPIC="${FROM_TOPICS[0]}"
    FROM_SLUG=$(echo "$FROM_TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
    FROM_FILE="$TOPICS_DIR/$FROM_SLUG.md"
    
    if [ ! -f "$FROM_FILE" ]; then
      echo "❌ Topic not found: $FROM_TOPIC"
      exit 1
    fi
    
    echo "⚠️  Deleting topic: $FROM_TOPIC"
    echo "   File: $FROM_FILE"
    echo ""
    read -p "Are you sure? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
      rm "$FROM_FILE"
      echo "✅ Deleted!"
    else
      echo "❌ Cancelled"
    fi
    ;;
    
  *)
    echo "Usage: manage-topics.sh --action <action> [options]"
    echo ""
    echo "Actions:"
    echo "  list              List all topics"
    echo "  merge             Merge multiple topics into one"
    echo "                    --from \"topic-a\" \"topic-b\" --to \"merged\""
    echo "  rename            Rename a topic"
    echo "                    --from \"old-name\" --to \"new-name\""
    echo "  delete            Delete a topic"
    echo "                    --from \"topic-name\""
    echo ""
    exit 1
    ;;
esac
