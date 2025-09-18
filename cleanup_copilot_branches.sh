#!/bin/bash

# Script to remove all Copilot-generated branches from the repository
# Usage: ./cleanup_copilot_branches.sh

set -e

echo "🧹 Cleaning up Copilot-generated branches..."

# List of Copilot branches to remove
COPILOT_BRANCHES=(
    "copilot/fix-c746140c-423d-4fd9-81c6-77d88a5f40e2"
    "copilot/fix-d0bfcbf4-2c6b-44c0-8456-3c84a31d5674"
)

echo "📋 Branches to be removed:"
for branch in "${COPILOT_BRANCHES[@]}"; do
    echo "  - $branch"
done

# Confirm before proceeding
read -p "❓ Do you want to proceed with deleting these branches? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled."
    exit 1
fi

echo "🗑️  Deleting remote branches..."

# Delete each remote branch
for branch in "${COPILOT_BRANCHES[@]}"; do
    echo "  Deleting remote branch: $branch"
    if git push origin --delete "$branch" 2>/dev/null; then
        echo "  ✅ Successfully deleted: $branch"
    else
        echo "  ⚠️  Branch may not exist or already deleted: $branch"
    fi
done

# Delete local tracking branches
echo "🗑️  Cleaning up local tracking references..."
for branch in "${COPILOT_BRANCHES[@]}"; do
    if git branch -r | grep -q "origin/$branch"; then
        echo "  Removing local tracking ref for: $branch"
        git branch -r -d "origin/$branch" 2>/dev/null || true
    fi
done

# Prune remote tracking branches
echo "🔄 Pruning remote tracking branches..."
git remote prune origin

echo "✅ Cleanup completed!"
echo ""
echo "🔍 Current branches:"
git branch -a

echo ""
echo "📝 Verify that no 'copilot/' branches remain in the output above."