#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") <branch> [source-dir]"
    echo ""
    echo "Creates an ephemeral git worktree in /tmp"
    echo ""
    echo "Arguments:"
    echo "  branch      Branch name to checkout"
    echo "  source-dir  Path to git repo (default: current directory)"
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

BRANCH="$1"
SOURCE_DIR="${2:-.}"

# Resolve to absolute path
SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"

# Verify it's a git repo
if ! git -C "$SOURCE_DIR" rev-parse --git-dir &>/dev/null; then
    echo "Error: '$SOURCE_DIR' is not a git repository" >&2
    exit 1
fi

# Get repo name for the temp directory
REPO_NAME="$(basename "$SOURCE_DIR")"

# Create unique temp directory name
WORKTREE_DIR="/tmp/${REPO_NAME}-${BRANCH//\//-}"

# Check if worktree already exists and is valid
if [[ -d "$WORKTREE_DIR" ]]; then
    echo "Worktree already exists at: $WORKTREE_DIR"
    echo "cd $WORKTREE_DIR"
    exit 0
fi

# Check if worktree is registered but directory is missing (stale)
if git -C "$SOURCE_DIR" worktree list --porcelain | grep -q "^worktree $WORKTREE_DIR$"; then
    echo "Pruning stale worktree registration..."
    git -C "$SOURCE_DIR" worktree prune
fi

# Create the worktree
echo "Creating worktree for branch '$BRANCH'..."
git -C "$SOURCE_DIR" worktree add "$WORKTREE_DIR" "$BRANCH"

echo ""
echo "Worktree created at: $WORKTREE_DIR"
echo ""
echo "To enter:"
echo "  cd $WORKTREE_DIR"
echo ""
echo "To clean up:"
echo "  git -C $SOURCE_DIR worktree remove $WORKTREE_DIR"
