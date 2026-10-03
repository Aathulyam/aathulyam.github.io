#!/usr/bin/env fish

# ============================================================
# Athulyam GitHub Auto-Sync
# Watches the repository and automatically commits + pushes
# ============================================================

set REPO_DIR (pwd)

# Allow an optional repository path
if test (count $argv) -ge 1
    set REPO_DIR $argv[1]
end

if not test -d "$REPO_DIR/.git"
    echo "❌ Not a Git repository:"
    echo "   $REPO_DIR"
    exit 1
end

cd $REPO_DIR

echo ""
echo "🔥 ATHULYAM GITHUB AUTO-SYNC"
echo "================================"
echo "Repository: "(pwd)
echo "Watching for changes..."
echo "Press Ctrl+C to stop."
echo ""

while true

    # Wait for a filesystem change.
    inotifywait \
        -r \
        -q \
        -e close_write \
        -e create \
        -e delete \
        -e moved_to \
        --exclude '(^|/)\.git(/|$)' \
        .

    # Give editors a moment to finish writing files.
    sleep 2

    # Check whether Git actually sees a change.
    if test -z (git status --porcelain)
        continue
    end

    echo ""
    echo "────────────────────────────────────"
    echo "🔧 Change detected"
    echo ""

    git status --short

    # Stage everything.
    git add -A

    # Generate a timestamped commit message.
    set TIMESTAMP (date "+%Y-%m-%d %H:%M:%S")

    git commit -m "Auto-sync: $TIMESTAMP"

    if test $status -ne 0
        echo "⚠️ Commit failed."
        continue
    end

    echo ""
    echo "🚀 Pushing to GitHub..."

    git push

    if test $status -eq 0
        echo "✅ GitHub updated successfully."
    else
        echo "❌ GitHub push failed."
        echo "   Check your network or Git credentials."
    end

    echo ""
    echo "👀 Watching for the next change..."

end
