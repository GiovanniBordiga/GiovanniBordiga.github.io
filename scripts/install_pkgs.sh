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

pip install -r requirements.txt
exit 0
