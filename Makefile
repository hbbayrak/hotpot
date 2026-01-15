.PHONY: html clean help

help:
	@echo "Available targets:"
	@echo "  html   - Build HTML documentation"
	@echo "  clean  - Remove build artifacts"

html:
	sphinx-build -b html . _build/html
	@echo ""
	@echo "Build complete. Open _build/html/index.html to view."

clean:
	rm -rf _build
