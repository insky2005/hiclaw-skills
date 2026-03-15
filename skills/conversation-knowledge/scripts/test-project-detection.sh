#!/bin/bash
# Test project directory detection logic

echo "🧪 Testing Project Directory Detection"
echo "======================================="
echo ""

find_project_dir() {
  local SCRIPT_DIR="$1"
  local current_dir="$SCRIPT_DIR"
  local max_depth=10
  local depth=0
  
  while [ $depth -lt $max_depth ]; do
    local dir_name=$(basename "$current_dir")
    local parent_dir=$(dirname "$current_dir")
    
    if [ "$dir_name" = ".agent" ] || [ "$dir_name" = ".openclaw" ]; then
      echo "$parent_dir"
      return 0
    fi
    
    current_dir="$parent_dir"
    depth=$((depth + 1))
  done
  
  echo "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
}

test_case() {
  local name="$1"
  local script_dir="$2"
  local expected="$3"
  
  local result=$(find_project_dir "$script_dir")
  local knowledge_dir="$result/.conversation-knowledge"
  
  if [ "$result" = "$expected" ]; then
    echo "✅ $name"
  else
    echo "❌ $name"
    echo "   Expected: $expected"
    echo "   Got:      $result"
  fi
  echo "   Script:  $script_dir"
  echo "   Project: $result"
  echo "   Knowledge: $knowledge_dir"
  echo ""
}

# Test Case 1: .agent installation
test_case \
  "Case 1: .agent installation" \
  "/home/user/my-project/.agent/skills/conversation-knowledge/scripts" \
  "/home/user/my-project"

# Test Case 2: .openclaw installation
test_case \
  "Case 2: .openclaw installation" \
  "/home/user/project/.openclaw/skills/conversation-knowledge/scripts" \
  "/home/user/project"

# Test Case 3: Deep nested path
test_case \
  "Case 3: Deep nested path" \
  "/opt/apps/hiclaw/projects/test-project/.agent/skills/conversation-knowledge/scripts" \
  "/opt/apps/hiclaw/projects/test-project"

# Test Case 4: Current development path (no .agent/.openclaw)
test_case \
  "Case 4: Development (fallback)" \
  "/root/manager-workspace/hiclaw-skills/skills/conversation-knowledge/scripts" \
  "/root/manager-workspace"

echo "✅ All tests complete!"
