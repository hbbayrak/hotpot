# Sphinx configuration for CCD Documentation
# https://www.sphinx-doc.org/en/master/usage/configuration.html

project = 'CCD Data Stewardship Platform'
copyright = '2024'
author = 'CCD Team'

# Extensions
extensions = [
    'myst_parser',
]

# MyST parser settings
myst_enable_extensions = [
    'colon_fence',
    'deflist',
]
myst_heading_anchors = 3

# Source settings
source_suffix = {
    '.md': 'markdown',
}
master_doc = 'index'
exclude_patterns = ['_build', 'scripts', 'SETUP.md', 'CLAUDE.md', '.git', '.venv']

# HTML output settings
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_title = 'CCD Documentation'

# Theme options
html_theme_options = {
    'navigation_depth': 4,
    'collapse_navigation': False,
    'sticky_navigation': True,
    'includehidden': True,
    'titles_only': False,
}
