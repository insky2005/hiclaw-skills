#!/bin/bash
# Diagnose project directory detection

echo "🔍 Diagnosing Project Directory Detection"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📍 Current Location:"
echo "   SCRIPT_DIR: $SCRIPT_DIR"
echo ""

echo "📁 Directory Structure:"
echo "   Level 0: $(basename "$SCRIPT_DIR")"
echo "   Level 1: $(basename "$(dirname "$SCRIPT_DIR")")"
echo "   Level 2: $(basename "$(dirname "$(dirname "$SCRIPT_DIR")")")"
echo "   Level 3: $(basename "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")"
echo "   Level 4: $(basename "$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")")"
echo ""

# Define find_project_dir function directly (more reliable than sourcing)
find_project_dir() {
  local current_dir="$SCRIPT_DIR"
  local max_depth=10
  local depth=0
  
  while [ $depth -lt $max_depth ]; do
    local dir_name
    dir_name=$(basename "$current_dir")
    
    if [ "$dir_name" = ".agent" ] || [ "$dir_name" = ".agents" ] || [ "$dir_name" = ".openclaw" ]; then
      local parent_dir
      parent_dir=$(dirname "$current_dir")
      echo "$parent_dir"
      return 0
    fi
    
    current_dir=$(dirname "$current_dir")
    depth=$((depth + 1))
  done
  
  local level1 level2 level3
  level1=$(dirname "$SCRIPT_DIR")
  level2=$(dirname "$level1")
  level3=$(dirname "$level2")
  echo "$level3"
}

PROJECT_DIR=$(find_project_dir)
DEFAULT_KNOWLEDGE_DIR="$PROJECT_DIR/.conversation-knowledge"

echo "🎯 Detection Result:"
echo "   PROJECT_DIR: $PROJECT_DIR"
echo "   DEFAULT_KNOWLEDGE_DIR: $DEFAULT_KNOWLEDGE_DIR"
echo ""

# Check if PROJECT_DIR contains .agent or .openclaw
if [[ "$PROJECT_DIR" == *"/.agent"* ]] || [[ "$PROJECT_DIR" == *"/.openclaw"* ]]; then
  echo "❌ ERROR: PROJECT_DIR contains .agent or .openclaw"
  echo ""
  echo "   This should not happen!"
  echo "   Expected: /home/user/project"
  echo "   Got:      $PROJECT_DIR"
  echo ""
  echo "💡 Solution:"
  echo "   1. Delete config file: rm scripts/.knowledge-config.json"
  echo "   2. Re-run initialization: bash scripts/init-knowledge.sh"
  echo "   3. Or manually specify the correct path when prompted"
  exit 1
else
  echo "✅ CORRECT: PROJECT_DIR does not contain .agent or .openclaw"
  echo ""
  echo "   Project directory correctly detected!"
fi

echo ""
echo "📋 Configuration File:"
CONFIG_FILE="$SCRIPT_DIR/.knowledge-config.json"
if [ -f "$CONFIG_FILE" ]; then
  echo "   ✅ Exists: $CONFIG_FILE"
  echo "   Content:"
  cat "$CONFIG_FILE" | sed 's/^/      /'
else
  echo "   ℹ️  Not found (will be created on initialization)"
fi

echo ""
echo "=========================================="
echo "Diagnosis complete!"
