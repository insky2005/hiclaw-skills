#!/bin/bash
# Test script for new initialization flow

echo "🧪 Testing Conversation Knowledge Initialization"
echo "================================================"
echo ""

# Test 1: Check if config exists
echo "Test 1: Check existing configuration"
echo "-------------------------------------"
if [ -f "scripts/.knowledge-config.json" ]; then
  echo "✅ Config file exists"
  cat scripts/.knowledge-config.json | head -10
else
  echo "ℹ️  No existing config (first run)"
fi
echo ""

# Test 2: Run initialization (non-interactive)
echo "Test 2: Run initialization (non-interactive)"
echo "---------------------------------------------"
echo "y" | bash scripts/init-knowledge.sh 2>&1 | tail -20
echo ""

# Test 3: Verify config created
echo "Test 3: Verify configuration"
echo "-----------------------------"
if [ -f "scripts/.knowledge-config.json" ]; then
  echo "✅ Config created successfully"
  echo "Knowledge directory:"
  cat scripts/.knowledge-config.json | grep knowledge_dir
else
  echo "❌ Config not created"
fi
echo ""

echo "✅ Tests complete!"
