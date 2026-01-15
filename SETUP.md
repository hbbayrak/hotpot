# Notes Setup Guide

This project uses a **git worktree** approach to keep documentation/notes in a separate branch while making them accessible via symlinks in the main project.

## Why This Approach?

- **Clean fork**: Documentation changes don't pollute the main branch or PRs to upstream
- **Contextual docs**: README files appear in the right locations via symlinks
- **Separate history**: Notes have their own commit history
- **Easy sync**: Script handles moving new docs and creating symlinks

## Structure

```
hotpot/                          # Main branch (develop)
├── README.md                    # Original project README (tracked in main)
├── CLAUDE.md -> notes/CLAUDE.md # Symlink
├── scripts -> notes/scripts     # Symlink
├── notes/                       # Worktree (notes branch)
│   ├── CLAUDE.md
│   ├── SETUP.md                 # This file
│   ├── scripts/sync-notes.sh
│   ├── client/
│   │   ├── README.md
│   │   └── src/modules/*/README.md
│   └── server/
│       └── .../README.md
├── client/
│   └── README.md -> ../notes/client/README.md
└── server/
    └── .../README.md -> .../notes/server/.../README.md
```

## Initial Setup (New Clone)

If you've cloned the repo and want to set up the notes worktree:

```bash
# 1. Add the notes worktree
git worktree add ./notes notes

# 2. Create symlink for scripts
ln -s notes/scripts scripts

# 3. Run sync script to create all symlinks
./scripts/sync-notes.sh
```

That's it! The symlinks will be created and excluded from git tracking via `.git/info/exclude`.

## Creating New Documentation

When you add new `.md` files to the project:

```bash
# 1. Create your markdown file anywhere in the project
echo "# My New Doc" > client/src/components/MyComponent/README.md

# 2. Run sync to move it to notes and create symlink
./scripts/sync-notes.sh

# 3. Commit in notes worktree
cd notes && git add -A && git commit -m "Add MyComponent docs"
git push
```

## How It Works

### The Sync Script (`scripts/sync-notes.sh`)

1. Finds all `.md` files (except root `README.md`)
2. Moves them to `notes/` with mirrored directory structure
3. Creates relative symlinks in original locations
4. Updates `.git/info/exclude` to ignore symlinks (keeps main branch clean)
5. Creates `notes/.gitignore` to ensure files are tracked in notes branch

### Git Exclusions

The script manages `.git/info/exclude` (local-only, not tracked) with patterns like:
```
/notes/
/scripts
CLAUDE.md
client/README.md
server/**/README.md
```

This keeps the main branch clean while the `notes/.gitignore` negates these patterns so files are tracked in the notes branch.

## Working with Notes

### View docs in context
```bash
# Symlinks work transparently
cat client/README.md           # Shows content from notes/client/README.md
```

### Edit docs
```bash
# Edit via symlink (changes go to notes/)
vim client/README.md

# Or edit directly in notes/
vim notes/client/README.md
```

### Commit changes
```bash
cd notes
git add -A
git commit -m "Update documentation"
git push
```

### Switch to notes branch directly
```bash
cd notes
git log                        # See notes history
git status                     # See notes changes
```

## Troubleshooting

### Symlink not working
```bash
# Re-run sync script
./scripts/sync-notes.sh
```

### File shows in main branch git status
```bash
# Check if it's excluded
git check-ignore -v path/to/file.md

# If not excluded, re-run sync to update .git/info/exclude
./scripts/sync-notes.sh
```

### Notes worktree missing
```bash
# Re-add worktree
git worktree add ./notes notes
```

### Conflict between source and notes version
If you somehow have a file in both locations with different content, the sync script will:
- Create a `.bak` backup of the source file
- Keep the notes version
- Show a warning

## Removing the Setup

If you want to remove the notes setup:

```bash
# Remove worktree
git worktree remove notes

# Remove scripts symlink
rm scripts

# Remove all doc symlinks (they'll be broken anyway)
find . -name "*.md" -type l -delete

# Clear exclusions (optional)
# Edit .git/info/exclude and remove the managed entries
```
