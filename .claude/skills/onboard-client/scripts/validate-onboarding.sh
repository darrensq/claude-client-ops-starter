#!/bin/bash
# validate-onboarding.sh
# Validates that client onboarding created the expected folder structure and files.
#
# Unlike the meeting-notes validator, this one is advisory in spirit but still
# exits 1 — the message goes back to Claude so it can fix what's missing.

read -r INPUT  # Stop event JSON from stdin

# Ensure we're in the project root
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null

# Find client files created in the last 30 minutes
MODIFIED=$(find Clients/ -name "*.md" -mmin -30 -type f -not -path "*/Templates/*" -not -path "*/Archive/*" 2>/dev/null)

WARNINGS=""

if [ -z "$MODIFIED" ]; then
  WARNINGS="No client files were created in the last 30 minutes. Onboarding may not have completed."
else
  # Check that at least a Client Profile exists
  HAS_PROFILE=$(echo "$MODIFIED" | grep -i "Client Profile" 2>/dev/null)
  if [ -z "$HAS_PROFILE" ]; then
    WARNINGS="${WARNINGS}No Client Profile file found among created files. "
  fi

  # Check that at least a Decision Log exists
  HAS_DECLOG=$(echo "$MODIFIED" | grep -i "Decision Log" 2>/dev/null)
  if [ -z "$HAS_DECLOG" ]; then
    WARNINGS="${WARNINGS}No Decision Log file found among created files. "
  fi

  # Validate frontmatter on all created files
  while IFS= read -r file; do
    if [ -n "$file" ]; then
      FIRST_LINE=$(head -1 "$file" 2>/dev/null)
      if [ "$FIRST_LINE" != "---" ]; then
        WARNINGS="${WARNINGS}Missing YAML frontmatter: ${file}. "
      fi
    fi
  done <<< "$MODIFIED"
fi

# Check that client-mappings was updated — without this, client detection
# won't route this client's meetings anywhere.
MAPPINGS_MOD=$(find .claude/references/client-mappings.md -mmin -30 2>/dev/null)
if [ -z "$MAPPINGS_MOD" ]; then
  WARNINGS="${WARNINGS}client-mappings.md was not updated with the new client. "
fi

if [ -n "$WARNINGS" ]; then
  echo "$WARNINGS"
  exit 1
fi

exit 0
