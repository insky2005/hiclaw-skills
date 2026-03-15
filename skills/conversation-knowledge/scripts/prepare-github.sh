#!/bin/bash
# Prepare conversation-knowledge for GitHub submission

set -e

SKILL_DIR="/root/manager-workspace/.openclaw/skills/conversation-knowledge"

echo "🚀 Preparing conversation-knowledge for GitHub..."
echo ""

# Step 1: Check required files
echo "Step 1: Checking required files..."
REQUIRED_FILES=("README.md" "LICENSE" "INSTALL.md" "COMMANDS.md" ".gitignore")
for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$SKILL_DIR/$file" ]; then
    echo "   ✅ $file"
  else
    echo "   ❌ $file (missing)"
  fi
done
echo ""

# Step 2: Remove internal references
echo "Step 2: Cleaning internal paths..."

# Create backup of README
if [ -f "$SKILL_DIR/README.md" ]; then
  cp "$SKILL_DIR/README.md" "$SKILL_DIR/README.md.internal"
  echo "   ✅ Backed up internal README"
fi

# Copy GitHub README to main README
if [ -f "$SKILL_DIR/GITHUB-README.md" ]; then
  cp "$SKILL_DIR/GITHUB-README.md" "$SKILL_DIR/README.md"
  echo "   ✅ Set GitHub README as main README"
fi
echo ""

# Step 3: Remove migration-specific files
echo "Step 3: Cleaning migration files..."
if [ -f "$SKILL_DIR/MIGRATION.md" ]; then
  echo "   ⚠️  MIGRATION.md found (internal file)"
  echo "      This will be excluded via .gitignore"
fi
echo ""

# Step 4: Check for sensitive data
echo "Step 4: Checking for sensitive data..."
SENSITIVE_PATTERNS=("password" "secret" "token" "api_key" "credential")
FOUND_SENSITIVE=false

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if grep -ri "$pattern" "$SKILL_DIR/scripts/" 2>/dev/null | grep -v ".git" | head -1 > /dev/null; then
    echo "   ⚠️  Found '$pattern' in scripts (please review)"
    FOUND_SENSITIVE=true
  fi
done

if [ "$FOUND_SENSITIVE" = false ]; then
  echo "   ✅ No obvious sensitive data found"
fi
echo ""

# Step 5: Initialize git (if not already)
echo "Step 5: Git repository setup..."
cd "$SKILL_DIR"

if [ ! -d ".git" ]; then
  git init
  echo "   ✅ Initialized git repository"
else
  echo "   ℹ️  Git repository already exists"
fi
echo ""

# Step 6: Show next steps
echo "==================================="
echo "✅ Preparation complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Review changes:"
echo "   cd $SKILL_DIR"
echo "   git status"
echo ""
echo "2. Add files:"
echo "   git add ."
echo ""
echo "3. Create initial commit:"
echo "   git commit -m 'Initial commit: conversation-knowledge skill'"
echo ""
echo "4. Create GitHub repository:"
echo "   - Go to https://github.com/new"
echo "   - Create repo: conversation-knowledge"
echo "   - Copy the remote URL"
echo ""
echo "5. Push to GitHub:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/conversation-knowledge.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "6. Update README with your username:"
echo "   - Replace YOUR_USERNAME in README.md"
echo "   - Commit and push"
echo ""
echo "==================================="
echo ""
echo "📁 Files ready for commit:"
ls -la "$SKILL_DIR" | grep -v "^d" | tail -n +2
echo ""
