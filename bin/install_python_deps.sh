#!/bin/bash
# Install Python dependencies for the citation-update script in Claude Code
# cloud sessions (e.g. scheduled Routine runs). See bin/update_scholar_citations.py.
#
# Runs only in cloud sessions and no-ops when the packages are already present,
# so it stays cheap on a warm environment cache and never touches local machines.

# Cloud-only: CLAUDE_CODE_REMOTE is "true" in Claude Code on the web sessions.
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  exit 0
fi

# Skip if dependencies are already importable (cache warm).
if python -c "import scholarly, yaml" 2>/dev/null; then
  exit 0
fi

# scholarly pulls in bibtexparser, which still ships a legacy setup.py build.
# The system setuptools (Debian-patched, from /usr/lib/python3/dist-packages)
# fails that build with "AttributeError: install_layout", so upgrade
# setuptools/wheel into user site-packages first to avoid touching the
# Debian-managed system packages.
pip install --user --upgrade setuptools wheel
pip install --user -r requirements.txt
