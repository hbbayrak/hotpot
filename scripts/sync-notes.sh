#!/bin/bash
# Sync documentation files to notes worktree with symlinks
# - Moves .md files (except root README.md) to notes/ worktree
# - Creates symlinks in original locations
# - Updates .git/info/exclude to ignore symlinks (keeps fork clean)

set -e

# Handle case where script is in notes/scripts/ (accessed via symlink)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ "$SCRIPT_DIR" == */notes/scripts ]]; then
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
else
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi
NOTES_ROOT="$PROJECT_ROOT/notes"
EXCLUDE_FILE="$PROJECT_ROOT/.git/info/exclude"
EXCLUDE_MARKER="# >>> sync-notes managed entries >>>"
EXCLUDE_END="# <<< sync-notes managed entries <<<"

if [ ! -d "$NOTES_ROOT/.git" ] && [ ! -f "$NOTES_ROOT/.git" ]; then
    echo "Error: notes worktree not found at ./notes"
    echo "Run: git worktree add ./notes notes"
    exit 1
fi

echo "Project root: $PROJECT_ROOT"
echo "Notes root: $NOTES_ROOT"
echo ""

# Create temp file for tracking paths
TEMP_PATHS="$PROJECT_ROOT/.sync-notes-paths.tmp"
rm -f "$TEMP_PATHS"

# Find all .md files, excluding:
# - Root README.md (tracked in main project)
# - node_modules, .git, notes directories
find "$PROJECT_ROOT" \
    -name "*.md" \
    -not -path "$PROJECT_ROOT/README.md" \
    -not -path "$PROJECT_ROOT/node_modules/*" \
    -not -path "$PROJECT_ROOT/.git/*" \
    -not -path "$PROJECT_ROOT/notes/*" \
    -not -path "*/node_modules/*" \
    | while read -r src_file; do

    # Calculate relative path from project root
    rel_path="${src_file#$PROJECT_ROOT/}"
    dest_file="$NOTES_ROOT/$rel_path"
    dest_dir="$(dirname "$dest_file")"

    # Track for exclusion
    echo "$rel_path" >> "$TEMP_PATHS"

    # Skip if already a symlink
    if [ -L "$src_file" ]; then
        echo "SKIP (symlink): $rel_path"
        continue
    fi

    echo "Processing: $rel_path"

    # Create destination directory
    mkdir -p "$dest_dir"

    # Move file to notes (if not already there)
    if [ -f "$src_file" ] && [ ! -f "$dest_file" ]; then
        mv "$src_file" "$dest_file"
        echo "  Moved to notes"
    elif [ -f "$dest_file" ]; then
        # File exists in both places - check if different
        if ! cmp -s "$src_file" "$dest_file"; then
            echo "  WARNING: Files differ! Backing up source to $rel_path.bak"
            mv "$src_file" "$src_file.bak"
        else
            rm -f "$src_file"
            echo "  Using existing notes version (identical)"
        fi
    fi

    # Create relative symlink
    src_dir="$(dirname "$src_file")"
    rel_to_notes="$(python3 -c "import os.path; print(os.path.relpath('$dest_file', '$src_dir'))")"
    ln -sf "$rel_to_notes" "$src_file"
    echo "  Symlinked: $rel_to_notes"
done

# Update .git/info/exclude
echo ""
echo "Updating .git/info/exclude..."

# Remove old managed entries
if grep -q "$EXCLUDE_MARKER" "$EXCLUDE_FILE" 2>/dev/null; then
    sed -i.bak "/$EXCLUDE_MARKER/,/$EXCLUDE_END/d" "$EXCLUDE_FILE"
    rm -f "$EXCLUDE_FILE.bak"
fi

# Add new managed entries
{
    echo ""
    echo "$EXCLUDE_MARKER"
    echo "# Notes worktree (tracked in notes branch)"
    echo "/notes/"
    echo "/scripts"
    echo ""
    echo "# Documentation symlinks"
    if [ -f "$TEMP_PATHS" ]; then
        sort -u "$TEMP_PATHS"
    fi
    echo "$EXCLUDE_END"
} >> "$EXCLUDE_FILE"

rm -f "$TEMP_PATHS"

# Create .gitignore in notes worktree to negate exclude patterns
NOTES_GITIGNORE="$NOTES_ROOT/.gitignore"
echo "Creating notes/.gitignore to override exclude patterns..."
cat > "$NOTES_GITIGNORE" << 'EOF'
# Override .git/info/exclude patterns for notes worktree
# Negate all patterns so they're tracked in this branch
!CLAUDE.md
!**/README.md
!scripts/

# Ignore macOS files
.DS_Store
EOF

echo "Done!"
echo ""
echo "Summary:"
echo "- Notes location: $NOTES_ROOT"
echo "- Exclusions added to: $EXCLUDE_FILE"
echo ""
echo "Next steps:"
echo "  cd notes && git add -A && git commit -m 'Update notes'"
