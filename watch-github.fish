#!/usr/bin/env fish

# ============================================================
# Athulyam GitHub Auto-Sync
# Watches the repository and automatically commits + pushes
#
# Safe behavior:
#   - Never touches .git
#   - Never force-pushes
#   - Never silently merges remote changes
#   - Retries failed pushes
#   - Detects previously unpushed commits
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

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

set RETRY_DELAY 10
set SETTLE_DELAY 2

# ------------------------------------------------------------
# Helper: check whether local main is ahead of origin/main
# ------------------------------------------------------------

function has_unpushed_commits
    set counts (git rev-list --left-right --count origin/main...HEAD 2>/dev/null)

    if test $status -ne 0
        return 1
    end

    set behind $counts[1]
    set ahead $counts[2]

    test "$ahead" -gt 0
end

# ------------------------------------------------------------
# Helper: check whether remote is ahead of local
# ------------------------------------------------------------

function remote_is_ahead
    set counts (git rev-list --left-right --count origin/main...HEAD 2>/dev/null)

    if test $status -ne 0
        return 1
    end

    set behind $counts[1]
    set ahead $counts[2]

    test "$behind" -gt 0
end

# ------------------------------------------------------------
# Helper: push pending commits
# ------------------------------------------------------------

function push_pending
    while has_unpushed_commits

        echo ""
        echo "🚀 Pushing pending Athulyam commits..."

        git push

        if test $status -eq 0
            echo "✅ GitHub updated successfully."
            return 0
        end

        echo "⚠️ Push failed."
        echo "   Retrying in $RETRY_DELAY seconds..."
        sleep $RETRY_DELAY

        # Refresh remote information before retrying.
        git fetch origin --quiet

        if remote_is_ahead
            echo ""
            echo "🛑 Remote repository changed while pushing."
            echo "   Automatic sync paused for safety."
            echo ""
            echo "   Run:"
            echo "   git status -sb"
            echo "   git log --oneline --graph --decorate --all -10"
            return 1
        end
    end

    return 0
end

# ------------------------------------------------------------
# Startup
# ------------------------------------------------------------

echo ""
echo "🔥 ATHULYAM GITHUB AUTO-SYNC"
echo "================================"
echo "Repository: "(pwd)
echo "Branch: "(git branch --show-current)
echo "Remote: "(git remote get-url origin)
echo ""
echo "Watching for changes..."
echo "Press Ctrl+C to stop."
echo ""

# ------------------------------------------------------------
# Main watcher
# ------------------------------------------------------------

while true

    # --------------------------------------------------------
    # First check whether previous commits are waiting to push.
    # --------------------------------------------------------

    git fetch origin --quiet

    if remote_is_ahead
        echo ""
        echo "🛑 GitHub has changes not present locally."
        echo "   Automatic sync paused for safety."
        echo ""
        echo "   Resolve the divergence manually before continuing."
        echo "   Use:"
        echo "     git status -sb"
        echo "     git log --oneline --graph --decorate --all -10"
        echo ""

        sleep 30
        continue
    end

    if has_unpushed_commits
        push_pending
    end

    # --------------------------------------------------------
    # Wait for a filesystem change.
    # --------------------------------------------------------

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
    sleep $SETTLE_DELAY

    echo ""
    echo "────────────────────────────────────"
    echo "🔧 Change detected"
    echo ""

    # --------------------------------------------------------
    # Check whether Git actually sees a change.
    # --------------------------------------------------------

    if test -z (git status --porcelain)
        continue
    end

    git status --short

    # --------------------------------------------------------
    # Refresh remote before creating a commit.
    # --------------------------------------------------------

    git fetch origin --quiet

    if remote_is_ahead
        echo ""
        echo "🛑 GitHub changed before this update could be committed."
        echo "   Automatic sync paused for safety."
        echo ""
        echo "   Resolve the remote/local difference manually."
        continue
    end

    # --------------------------------------------------------
    # Stage everything.
    # --------------------------------------------------------

    git add -A

    if test $status -ne 0
        echo "❌ git add failed."
        continue
    end

    # --------------------------------------------------------
    # Commit.
    # --------------------------------------------------------

    set TIMESTAMP (date "+%Y-%m-%d %H:%M:%S")

    git commit -m "Auto-sync: $TIMESTAMP"

    if test $status -ne 0
        echo "⚠️ Commit failed."
        continue
    end

    echo ""
    echo "📦 Commit created."

    # --------------------------------------------------------
    # Push.
    # --------------------------------------------------------

    push_pending

    echo ""
    echo "👀 Watching for the next change..."
end
