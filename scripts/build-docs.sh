#!/bin/bash
# Build Sphinx documentation for CCD platform
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VENV_DIR="$NOTES_DIR/.venv"

cd "$NOTES_DIR"

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Install dependencies if needed
if ! python -c "import sphinx" 2>/dev/null; then
    echo "Installing Sphinx dependencies..."
    pip install -q -r requirements-docs.txt
fi

# Build HTML documentation
echo "Building documentation..."
sphinx-build -b html . _build/html

echo ""
echo "Documentation built successfully!"
echo "Open: file://$NOTES_DIR/_build/html/index.html"
