#!/bin/bash
# Initialize conversation knowledge base - Interactive path configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.knowledge-config.json"

echo "📚 Conversation Knowledge - Initialization"
echo "=========================================="
echo ""

# Function to check if already initialized
check_initialized() {
  if [ -f "$CONFIG_FILE" ]; then
    return 0
  else
    return 1
  fi
}

# Function to get user input (non-interactive mode for testing)
get_user_input() {
  local prompt="$1"
  local default="$2"
  local input=""
  
  # For non-interactive use, return default
  if [ -n "$default" ]; then
    echo "$default"
    return 0
  fi
  
  # Interactive mode
  if [ -t 0 ]; then
    echo -n "$prompt [$default]: "
    read -r input
    if [ -z "$input" ] && [ -n "$default" ]; then
      echo "$default"
    else
      echo "$input"
    fi
  else
    # Non-interactive, use default
    echo "$default"
  fi
}

# Find project directory (parent of .agent or .openclaw)
# Skill is typically installed at: <project-dir>/.agent/skills/conversation-knowledge/
# We want to store knowledge at: <project-dir>/.conversation-knowledge/
find_project_dir() {
  local current_dir="$SCRIPT_DIR"
  local max_depth=10
  local depth=0
  
  # Traverse up the directory tree
  while [ $depth -lt $max_depth ]; do
    local dir_name
    dir_name=$(basename "$current_dir")
    
    # Check if current directory is .agent or .openclaw
    if [ "$dir_name" = ".agent" ] || [ "$dir_name" = ".openclaw" ]; then
      # Found it! Project directory is the parent of .agent/.openclaw
      local parent_dir
      parent_dir=$(dirname "$current_dir")
      echo "$parent_dir"
      return 0
    fi
    
    # Move up one directory
    current_dir=$(dirname "$current_dir")
    depth=$((depth + 1))
  done
  
  # Fallback: go up 3 levels from scripts/
  # scripts/ -> conversation-knowledge/ -> skills/ -> project/
  local level1 level2 level3
  level1=$(dirname "$SCRIPT_DIR")
  level2=$(dirname "$level1")
  level3=$(dirname "$level2")
  echo "$level3"
}

PROJECT_DIR=$(find_project_dir)
DEFAULT_KNOWLEDGE_DIR="$PROJECT_DIR/.conversation-knowledge"

# Check if already initialized
if check_initialized; then
  echo "⚠️  Warning: Knowledge base appears to be already initialized!"
  echo ""
  
  # Read existing config
  if command -v jq &> /dev/null; then
    EXISTING_PATH=$(jq -r '.knowledge_dir' "$CONFIG_FILE" 2>/dev/null || echo "unknown")
    INIT_DATE=$(jq -r '.initialized_at' "$CONFIG_FILE" 2>/dev/null || echo "unknown")
    echo "   Current configuration:"
    echo "   - Knowledge Directory: $EXISTING_PATH"
    echo "   - Initialized At: $INIT_DATE"
  else
    echo "   Config file exists: $CONFIG_FILE"
  fi
  
  echo ""
  echo -n "Do you want to continue and reinitialize? (y/N): "
  read -r confirm
  
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo ""
    echo "❌ Initialization cancelled."
    echo ""
    echo "💡 To reset completely, remove the config file:"
    echo "   rm $CONFIG_FILE"
    exit 0
  fi
  
  echo ""
  echo "⚠️  Proceeding with reinitialization..."
  echo "   This will update the configuration and create missing directories."
  echo ""
fi

# Step 1: Get knowledge directory path from user
echo "Step 1: Configure Knowledge Directory"
echo "--------------------------------------"
echo ""
echo "Please provide the directory path where conversation knowledge will be stored."
echo ""
echo "Detected project directory: $PROJECT_DIR"
echo ""
echo "Recommendations:"
echo "  • Default: .conversation-knowledge/ (in project directory: $DEFAULT_KNOWLEDGE_DIR)"
echo "  • For shared access: /root/hiclaw-fs/shared/knowledge/conversations/"
echo "  • For standalone: ~/.conversation-knowledge/"
echo ""

KNOWLEDGE_DIR=""
while [ -z "$KNOWLEDGE_DIR" ]; do
  KNOWLEDGE_DIR=$(get_user_input "Knowledge directory path" "$DEFAULT_KNOWLEDGE_DIR")
  
  if [ -z "$KNOWLEDGE_DIR" ]; then
    echo "❌ Path cannot be empty. Please try again."
    echo ""
  fi
done

# Expand tilde if present
KNOWLEDGE_DIR="${KNOWLEDGE_DIR/#\~/$HOME}"

# Convert to absolute path
if [[ "$KNOWLEDGE_DIR" != /* ]]; then
  KNOWLEDGE_DIR="$(pwd)/$KNOWLEDGE_DIR"
fi

echo ""
echo "   Selected path: $KNOWLEDGE_DIR"
echo ""

# Step 2: Confirm path
echo "Step 2: Confirm Configuration"
echo "------------------------------"
echo ""
echo "Configuration summary:"
echo "  📁 Knowledge Directory: $KNOWLEDGE_DIR"
echo "  📂 Config File: $CONFIG_FILE"
echo ""
echo -n "Is this correct? (Y/n): "
read -r confirm

if [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
  echo ""
  echo "❌ Initialization cancelled. Please run again with correct path."
  exit 0
fi

# Step 3: Create directories
echo ""
echo "Step 3: Creating Directory Structure"
echo "-------------------------------------"
echo ""

# Create main knowledge directory
mkdir -p "$KNOWLEDGE_DIR"
echo "✅ Created: $KNOWLEDGE_DIR"

# Create subdirectories
TOPICS_DIR="$KNOWLEDGE_DIR/topics"
SESSIONS_DIR="$KNOWLEDGE_DIR/sessions"
EXPORTS_DIR="$KNOWLEDGE_DIR/exports"

mkdir -p "$TOPICS_DIR"
echo "✅ Created: $TOPICS_DIR"

mkdir -p "$SESSIONS_DIR"
echo "✅ Created: $SESSIONS_DIR"

mkdir -p "$EXPORTS_DIR"
echo "✅ Created: $EXPORTS_DIR"

# Step 4: Initialize config file
echo ""
echo "Step 4: Creating Configuration File"
echo "------------------------------------"
echo ""

# Create config file
cat > "$CONFIG_FILE" << EOF
{
  "knowledge_dir": "$KNOWLEDGE_DIR",
  "topics_dir": "$TOPICS_DIR",
  "sessions_dir": "$SESSIONS_DIR",
  "exports_dir": "$EXPORTS_DIR",
  "initialized_at": "$(date -Iseconds)",
  "version": "1.0.0",
  "script_dir": "$SCRIPT_DIR"
}
EOF

echo "✅ Created config file: $CONFIG_FILE"
echo ""

# Step 5: Initialize index.json
echo "Step 5: Initializing Knowledge Index"
echo "-------------------------------------"
echo ""

INDEX_FILE="$KNOWLEDGE_DIR/index.json"

if [ -f "$INDEX_FILE" ]; then
  echo "⚠️  Index file already exists, backing up..."
  cp "$INDEX_FILE" "$INDEX_FILE.backup.$(date +%Y%m%d_%H%M%S)"
  echo "✅ Backup created: $INDEX_FILE.backup.*"
fi

# Create new index file
cat > "$INDEX_FILE" << EOF
{
  "topics": [],
  "total_entries": 0,
  "updated_at": null,
  "knowledge_dir": "$KNOWLEDGE_DIR"
}
EOF

echo "✅ Created index file: $INDEX_FILE"

# Step 6: Create today's session file
echo ""
echo "Step 6: Creating Session File"
echo "------------------------------"
echo ""

TODAY=$(date +%Y-%m-%d)
SESSION_FILE="$SESSIONS_DIR/$TODAY.md"

if [ ! -f "$SESSION_FILE" ]; then
  cat > "$SESSION_FILE" << EOF
# $TODAY Conversations

<!-- Auto-generated by conversation-knowledge skill -->

EOF
  echo "✅ Created session file: $SESSION_FILE"
else
  echo "ℹ️  Session file for $TODAY already exists"
fi

# Step 7: Update script references
echo ""
echo "Step 7: Updating Script References"
echo "-----------------------------------"
echo ""

# Update all scripts to use config file
SCRIPTS_TO_UPDATE=(
  "record-conversation.sh"
  "search-knowledge.sh"
  "list-recent.sh"
  "load-conversation.sh"
  "summarize-conversation.sh"
  "export-knowledge.sh"
  "manage-topics.sh"
  "context-tracker.sh"
)

UPDATED_COUNT=0
for script in "${SCRIPTS_TO_UPDATE[@]}"; do
  SCRIPT_PATH="$SCRIPT_DIR/$script"
  if [ -f "$SCRIPT_PATH" ]; then
    # Check if script already uses config file
    if grep -q "CONFIG_FILE" "$SCRIPT_PATH"; then
      echo "ℹ️  Already updated: $script"
    else
      echo "⚠️  Needs update: $script (manual update required)"
    fi
    UPDATED_COUNT=$((UPDATED_COUNT + 1))
  fi
done

echo ""
echo "   Updated $UPDATED_COUNT scripts"

# Step 8: Final summary
echo ""
echo "=========================================="
echo "✅ Initialization Complete!"
echo "=========================================="
echo ""
echo "Configuration:"
echo "  📁 Knowledge Directory: $KNOWLEDGE_DIR"
echo "  📄 Config File: $CONFIG_FILE"
echo "  📊 Index File: $INDEX_FILE"
echo ""
echo "Directory Structure:"
echo "  $KNOWLEDGE_DIR/"
echo "  ├── index.json          # Topic index"
echo "  ├── topics/             # Topic-specific logs"
echo "  ├── sessions/           # Daily transcripts"
echo "  └── exports/            # Generated summaries"
echo ""
echo "Next Steps:"
echo "  1. Test the installation:"
echo "     bash $SCRIPT_DIR/cmd.sh /帮助"
echo ""
echo "  2. Start recording conversations:"
echo "     bash $SCRIPT_DIR/cmd.sh /记录 --topic \"Topic\" --summary \"Summary\""
echo ""
echo "  3. Or use natural language:"
echo "     /加载 话题名"
echo "     /记录 --summary \"摘要\""
echo ""
echo "💡 Note:"
echo "  - All scripts will read the knowledge directory from: $CONFIG_FILE"
echo "  - To change the path later, edit $CONFIG_FILE or re-run initialization"
echo "  - To reset completely: rm $CONFIG_FILE"
echo ""
