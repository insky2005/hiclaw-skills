#!/bin/bash
# Register conversation-knowledge skill after container rebuild
# This script ensures the skill is properly linked and ready to use

set -e

SKILL_NAME="conversation-knowledge"
SKILL_SOURCE="/root/.openclaw/skills/$SKILL_NAME"
SKILL_TARGET="/opt/hiclaw/agent/skills/$SKILL_NAME"

echo "🔧 Registering $SKILL_NAME skill..."
echo ""

# Check if source exists
if [ ! -d "$SKILL_SOURCE" ]; then
  echo "❌ Skill not found at: $SKILL_SOURCE"
  echo ""
  echo "💡 The skill should be in /root/.openclaw/skills/ (persistent storage)"
  echo "   If you just rebuilt the container, the skill should still be there."
  echo "   If it's missing, you may need to restore from backup."
  exit 1
fi

# Check if already linked
if [ -d "$SKILL_TARGET" ]; then
  echo "ℹ️  Skill already registered at: $SKILL_TARGET"
  echo ""
  read -p "Do you want to re-link? (y/N): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "✅ Skill is ready to use!"
    exit 0
  fi
fi

# Create symbolic link
echo "📎 Creating symbolic link..."
rm -rf "$SKILL_TARGET" 2>/dev/null || true
ln -s "$SKILL_SOURCE" "$SKILL_TARGET"
echo "   $SKILL_SOURCE → $SKILL_TARGET"

# Ensure scripts are executable
echo ""
echo "🔨 Ensuring scripts are executable..."
chmod +x "$SKILL_SOURCE/scripts/"*.sh 2>/dev/null || true

# Check if knowledge base exists
KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
INDEX_FILE="$KNOWLEDGE_DIR/index.json"

echo ""
if [ -f "$INDEX_FILE" ]; then
  echo "✅ Knowledge base found: $KNOWLEDGE_DIR"
  
  # Count topics
  if command -v jq &> /dev/null; then
    TOPIC_COUNT=$(jq '.topics | length' "$INDEX_FILE" 2>/dev/null || echo "0")
    ENTRY_COUNT=$(jq '.total_entries' "$INDEX_FILE" 2>/dev/null || echo "0")
    echo "   Topics: $TOPIC_COUNT | Entries: $ENTRY_COUNT"
  fi
else
  echo "⚠️  Knowledge base not initialized yet"
  echo ""
  read -p "Initialize now? (y/N): " init_confirm
  if [ "$init_confirm" = "y" ] || [ "$init_confirm" = "Y" ]; then
    bash "$SKILL_SOURCE/scripts/init-knowledge.sh"
  fi
fi

echo ""
echo "✅ Skill registration complete!"
echo ""
echo "📚 Quick start:"
echo "   bash $SKILL_SOURCE/scripts/quickref.sh"
echo "   bash $SKILL_SOURCE/scripts/list-recent.sh"
echo ""
echo "💬 Or just say:"
echo "   '显示快速参考'"
echo "   '列出最近的对话'"
