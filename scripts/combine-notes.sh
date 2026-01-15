#!/bin/bash
# Combine all notes into a single markdown document with proper hierarchy
# - Generates pandoc-ready output with YAML front matter
# - Creates breadcrumb headings for each section
# - Shifts content headings to fit under their section level
# - Adds page breaks between major sections

set -e

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ "$SCRIPT_DIR" == */notes/scripts ]]; then
    NOTES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
    NOTES_ROOT="$(cd "$SCRIPT_DIR/../notes" && pwd)"
fi

# Helper: shift heading levels by adding # characters
# Usage: shift_headings "content" depth
shift_headings() {
    local content="$1"
    local depth="$2"
    local prefix=""

    for ((i=0; i<depth; i++)); do
        prefix="${prefix}#"
    done

    # Add prefix to all lines starting with #
    echo "$content" | sed "s/^#/${prefix}#/g"
}

# Helper: strip first H1 from content (title is in breadcrumb)
strip_first_h1() {
    local content="$1"
    # Remove first line that starts with single # (not ##) using awk
    echo "$content" | awk '
        BEGIN { found = 0 }
        /^#[^#]/ && !found { found = 1; next }
        { print }
    '
}

# Helper: process a file and output with proper heading
# Usage: process_file "path" "breadcrumb" depth
process_file() {
    local file_path="$1"
    local breadcrumb="$2"
    local depth="$3"
    local heading_prefix=""

    # Create heading prefix based on depth (depth 2 = ##, depth 3 = ###)
    for ((i=0; i<depth; i++)); do
        heading_prefix="${heading_prefix}#"
    done

    if [ ! -f "$file_path" ]; then
        echo "<!-- WARNING: File not found: $file_path -->" >&2
        return
    fi

    # Output section heading
    echo ""
    echo "${heading_prefix} ${breadcrumb}"
    echo ""

    # Read file, strip first H1, shift remaining headings
    local content
    content=$(cat "$file_path")
    content=$(strip_first_h1 "$content")

    # Calculate how much to shift: if section is at depth N, content H2 should become H(N+1)
    # So we shift by (depth - 1) levels
    local shift=$((depth - 1))
    content=$(shift_headings "$content" "$shift")

    echo "$content"
}

# Count files and lines for metadata
count_files() {
    find "$NOTES_ROOT" -name "*.md" -not -name "*.bak" | wc -l | tr -d ' '
}

count_lines() {
    find "$NOTES_ROOT" -name "*.md" -not -name "*.bak" -exec cat {} \; | wc -l | tr -d ' '
}

# Generate the combined document
generate_document() {
    local today
    today=$(date +%Y-%m-%d)
    local file_count
    file_count=$(count_files)
    local line_count
    line_count=$(count_lines)

    # YAML front matter for pandoc
    cat << EOF
---
title: "CCD Data Stewardship Platform"
subtitle: "Complete Technical Documentation"
date: "$today"
toc: true
toc-depth: 4
documentclass: report
geometry: margin=1in
---

# CCD Documentation

> **Generated:** $today | **Files:** $file_count | **Lines:** ~$line_count

---

EOF

    # =========================================================================
    # SECTION 1: Overview (root-level docs)
    # =========================================================================
    echo "# Overview"
    echo ""

    # Root-level documentation files in order
    local root_docs=(
        "ARCHITECTURE.md:Architecture"
        "API.md:API Reference"
        "DEVELOPMENT.md:Development"
        "APP_SETUP.md:App Setup"
    )

    for entry in "${root_docs[@]}"; do
        local file="${entry%%:*}"
        local title="${entry##*:}"
        if [ -f "$NOTES_ROOT/$file" ]; then
            process_file "$NOTES_ROOT/$file" "$title" 2
        fi
    done

    # Page break
    echo ""
    echo "<!-- pagebreak -->"
    echo ""

    # =========================================================================
    # SECTION 2: Client
    # =========================================================================
    echo "# Client"
    echo ""

    # Client overview
    if [ -f "$NOTES_ROOT/client/README.md" ]; then
        process_file "$NOTES_ROOT/client/README.md" "Client › Overview" 2
    fi

    # Client hooks
    if [ -f "$NOTES_ROOT/client/src/hooks/README.md" ]; then
        process_file "$NOTES_ROOT/client/src/hooks/README.md" "Client › Hooks" 2
    fi

    # Client modules section
    echo ""
    echo "## Client › Modules"
    echo ""

    # Modules overview first
    if [ -f "$NOTES_ROOT/client/src/modules/README.md" ]; then
        process_file "$NOTES_ROOT/client/src/modules/README.md" "Client › Modules › Overview" 3
    fi

    # Individual modules (alphabetically)
    local modules_dir="$NOTES_ROOT/client/src/modules"
    if [ -d "$modules_dir" ]; then
        for module_dir in "$modules_dir"/*/; do
            if [ -d "$module_dir" ]; then
                local module_name
                module_name=$(basename "$module_dir")
                local module_readme="$module_dir/README.md"
                if [ -f "$module_readme" ]; then
                    process_file "$module_readme" "Client › Modules › $module_name" 3
                fi
            fi
        done
    fi

    # Page break
    echo ""
    echo "<!-- pagebreak -->"
    echo ""

    # =========================================================================
    # SECTION 3: Server
    # =========================================================================
    echo "# Server"
    echo ""

    # Server overview
    if [ -f "$NOTES_ROOT/server/README.md" ]; then
        process_file "$NOTES_ROOT/server/README.md" "Server › Overview" 2
    fi

    # Server Areas section
    echo ""
    echo "## Server › Areas"
    echo ""

    # Areas overview first
    local areas_dir="$NOTES_ROOT/server/Ccd.Server/Areas"
    if [ -f "$areas_dir/README.md" ]; then
        process_file "$areas_dir/README.md" "Server › Areas › Overview" 3
    fi

    # Individual areas (alphabetically)
    if [ -d "$areas_dir" ]; then
        for area_dir in "$areas_dir"/*/; do
            if [ -d "$area_dir" ]; then
                local area_name
                area_name=$(basename "$area_dir")
                local area_readme="$area_dir/README.md"
                if [ -f "$area_readme" ]; then
                    process_file "$area_readme" "Server › Areas › $area_name" 3
                fi
            fi
        done
    fi

    # Other server directories
    local server_dirs=(
        "server/Ccd.Server/Data:Server › Data"
        "server/Ccd.Server/Helpers:Server › Helpers"
        "server/Ccd.Server/Mappings:Server › Mappings"
        "server/Ccd.Server/Migrations:Server › Migrations"
        "server/Ccd.Server/Emails:Server › Emails"
        "server/Ccd.Tests:Server › Tests"
    )

    for entry in "${server_dirs[@]}"; do
        local dir="${entry%%:*}"
        local title="${entry##*:}"
        local readme="$NOTES_ROOT/$dir/README.md"
        if [ -f "$readme" ]; then
            process_file "$readme" "$title" 2
        fi
    done

    # Footer
    echo ""
    echo "---"
    echo ""
    echo "*End of documentation*"
}

# Main execution
generate_document
