#!/bin/bash
# Migrate conversation knowledge base to new location

set -e

OLD_DIR="/root/hiclaw-fs/shared/knowledge/conversations"
NEW_DIR="/root/host-home/.conversation-knowledge"

echo "🔄 Migrating Conversation Knowledge Base"
echo "========================================="
echo ""
echo "From: $OLD_DIR"
echo "To:   $NEW_DIR"
echo ""

# Step 1: Check source directory
if [ ! -d "$OLD_DIR" ]; then
  echo "❌ Source directory not found: $OLD_DIR"
  exit 1
fi
echo "✅ Source directory exists"

# Step 2: Create target directory
mkdir -p "$NEW_DIR"
echo "✅ Created target directory"

# Step 3: Copy data
echo "📦 Copying data..."
cp -r "$OLD_DIR"/* "$NEW_DIR/"
echo "✅ Data copied"

# Step 4: Update/create config file
CONFIG_FILE="$NEW_DIR/.knowledge-config.json"
cat > "$CONFIG_FILE" << EOF
{
  "knowledge_dir": "$NEW_DIR",
  "topics_dir": "$NEW_DIR/topics",
  "sessions_dir": "$NEW_DIR/sessions",
  "exports_dir": "$NEW_DIR/exports",
  "initialized_at": "$(date -Iseconds)",
  "version": "1.1.4",
  "migrated_from": "$OLD_DIR",
  "migrated_at": "$(date -Iseconds)"
}
EOF
echo "✅ Config file created: $CONFIG_FILE"

# Step 5: Verify
echo ""
echo "📊 Verification:"
echo "   Topics: $(ls "$NEW_DIR/topics"/*.md 2>/dev/null | wc -l) files"
echo "   Sessions: $(ls "$NEW_DIR/sessions"/*.md 2>/dev/null | wc -l) files"
echo "   Exports: $(ls "$NEW_DIR/exports"/*.md 2>/dev/null | wc -l) files"
echo ""

# Step 6: Update skill config if exists
SKILL_DIRS=(
  "/root/.openclaw/skills/conversation-knowledge/scripts"
  "/root/.agent/skills/conversation-knowledge/scripts"
  "/root/.agents/skills/conversation-knowledge/scripts"
)

for skill_dir in "${SKILL_DIRS[@]}"; do
  if [ -d "$skill_dir" ]; then
    echo "📝 Updating skill config in: $skill_dir"
    cp "$CONFIG_FILE" "$skill_dir/.knowledge-config.json"
    echo "   ✅ Config updated"
  fi
done

echo ""
echo "========================================="
echo "✅ Migration Complete!"
echo "========================================="
echo ""
echo "New location: $NEW_DIR"
echo ""
echo "Next steps:"
echo "1. Test the installation:"
echo "   cd $NEW_DIR && ls"
echo ""
echo "2. Update any hardcoded references to old path"
echo ""
echo "3. Optionally remove old directory (after verification):"
echo "   rm -rf $OLD_DIR"
echo ""
