#!/bin/bash
# Context Tracker - Track recent topic loads for smart recording
# Updated to use config file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.knowledge-config.json"

# Get knowledge directory from config
if [ -f "$CONFIG_FILE" ] && command -v jq &> /dev/null; then
  KNOWLEDGE_DIR=$(jq -r '.knowledge_dir' "$CONFIG_FILE" 2>/dev/null)
  if [ -z "$KNOWLEDGE_DIR" ] || [ "$KNOWLEDGE_DIR" = "null" ]; then
    KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
  fi
else
  KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
fi

CONTEXT_FILE="$KNOWLEDGE_DIR/.context.json"

# Ensure directory exists
mkdir -p "$KNOWLEDGE_DIR"

# Parse arguments
ACTION="$1"
shift

case "$ACTION" in
  set-topic)
    # Set current topic context
    TOPIC_NAME="$1"
    if [ -z "$TOPIC_NAME" ]; then
      echo "❌ Error: topic name required"
      exit 1
    fi
    
    # Get topic metadata
    SLUG=""
    INDEX_FILE="$KNOWLEDGE_DIR/index.json"
    if [ -f "$INDEX_FILE" ] && command -v jq &> /dev/null; then
      SLUG=$(jq -r --arg name "$TOPIC_NAME" '.topics[] | select(.name == $name) | .slug' "$INDEX_FILE" 2>/dev/null)
    fi
    
    # Write context
    cat > "$CONTEXT_FILE" << EOF
{
  "current_topic": "$TOPIC_NAME",
  "slug": "$SLUG",
  "set_at": "$(date -Iseconds)",
  "expires_at": "$(date -d '+1 hour' -Iseconds 2>/dev/null || date -Iseconds)"
}
EOF
    
    echo "✅ Context set: $TOPIC_NAME"
    ;;
  
  get-topic)
    # Get current topic context
    if [ ! -f "$CONTEXT_FILE" ]; then
      echo ""
      exit 0
    fi
    
    # Check if expired
    if command -v jq &> /dev/null; then
      EXPIRES_AT=$(jq -r '.expires_at' "$CONTEXT_FILE" 2>/dev/null || echo "")
      if [ -n "$EXPIRES_AT" ]; then
        EXPIRES_EPOCH=$(date -d "$EXPIRES_AT" +%s 2>/dev/null || echo "0")
        NOW_EPOCH=$(date +%s)
        if [ "$NOW_EPOCH" -gt "$EXPIRES_EPOCH" ]; then
          # Expired, clear context
          rm -f "$CONTEXT_FILE"
          echo ""
          exit 0
        fi
      fi
      
      TOPIC=$(jq -r '.current_topic' "$CONTEXT_FILE" 2>/dev/null || echo "")
      SLUG=$(jq -r '.slug' "$CONTEXT_FILE" 2>/dev/null || echo "")
      
      if [ -n "$TOPIC" ] && [ "$TOPIC" != "null" ]; then
        echo "$TOPIC"
      else
        echo ""
      fi
    else
      # Fallback without jq
      grep '"current_topic"' "$CONTEXT_FILE" 2>/dev/null | sed 's/.*: "\([^"]*\)".*/\1/' || echo ""
    fi
    ;;
  
  clear)
    # Clear context
    rm -f "$CONTEXT_FILE"
    echo "✅ Context cleared"
    ;;
  
  show)
    # Show current context
    if [ -f "$CONTEXT_FILE" ]; then
      echo "📍 Current Context:"
      cat "$CONTEXT_FILE"
    else
      echo "ℹ️  No active context"
    fi
    ;;
  
  *)
    echo "Usage: context-tracker.sh <action>"
    echo ""
    echo "Actions:"
    echo "  set-topic \"Topic Name\"  - Set current topic context"
    echo "  get-topic                 - Get current topic (empty if none)"
    echo "  clear                     - Clear context"
    echo "  show                      - Show current context"
    ;;
esac
