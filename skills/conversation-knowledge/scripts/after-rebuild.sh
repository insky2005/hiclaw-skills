#!/bin/bash
# Run this after container rebuild to restore conversation-knowledge skill

set -e

echo "🔄 Post-Rebuild Recovery for Conversation Knowledge Skill"
echo "=========================================================="
echo ""

SKILL_NAME="conversation-knowledge"
SKILL_HOME="/root/.openclaw/skills/$SKILL_NAME"
SKILL_LINK="/opt/hiclaw/agent/skills/$SKILL_NAME"
KNOWLEDGE_DIR="/root/hiclaw-fs/shared/knowledge/conversations"

# Step 1: Check if skill exists in persistent storage
echo "Step 1: Checking persistent storage..."
if [ -d "$SKILL_HOME" ]; then
  echo "✅ Skill found: $SKILL_HOME"
else
  echo "❌ Skill NOT found in persistent storage!"
  echo ""
  echo "💡 This is unexpected. The skill should be in /root/.openclaw/skills/"
  echo "   If you haven't backed up, you may need to recreate the skill."
  exit 1
fi

# Step 2: Recreate symbolic link
echo ""
echo "Step 2: Recreating symbolic link..."
rm -rf "$SKILL_LINK" 2>/dev/null || true
ln -s "$SKILL_HOME" "$SKILL_LINK"
echo "✅ Linked: $SKILL_LINK → $SKILL_HOME"

# Step 3: Ensure scripts are executable
echo ""
echo "Step 3: Ensuring scripts are executable..."
chmod +x "$SKILL_HOME/scripts/"*.sh 2>/dev/null || true
echo "✅ Scripts are executable"

# Step 4: Check knowledge base
echo ""
echo "Step 4: Checking knowledge base..."
if [ -d "$KNOWLEDGE_DIR" ]; then
  echo "✅ Knowledge base directory exists: $KNOWLEDGE_DIR"
  
  if [ -f "$KNOWLEDGE_DIR/index.json" ]; then
    echo "✅ Knowledge index found"
    
    if command -v jq &> /dev/null; then
      TOPIC_COUNT=$(jq '.topics | length' "$KNOWLEDGE_DIR/index.json" 2>/dev/null || echo "0")
      ENTRY_COUNT=$(jq '.total_entries' "$KNOWLEDGE_DIR/index.json" 2>/dev/null || echo "0")
      echo "   Topics: $TOPIC_COUNT | Entries: $ENTRY_COUNT"
    fi
  else
    echo "⚠️  Knowledge index not found - will be created on first use"
  fi
else
  echo "⚠️  Knowledge base directory not found"
  echo "   This should be synced from MinIO by file-sync skill"
fi

# Step 5: Test a command
echo ""
echo "Step 5: Testing skill..."
if bash "$SKILL_HOME/scripts/quickref.sh" > /dev/null 2>&1; then
  echo "✅ Skill is working correctly!"
else
  echo "❌ Skill test failed"
  exit 1
fi

echo ""
echo "=========================================================="
echo "✅ Recovery complete!"
echo ""
echo "📚 Quick commands:"
echo "   bash $SKILL_HOME/scripts/quickref.sh"
echo "   bash $SKILL_HOME/scripts/list-recent.sh"
echo ""
echo "💬 Or use natural language:"
echo "   '显示快速参考'"
echo "   '列出最近的对话'"
echo ""
