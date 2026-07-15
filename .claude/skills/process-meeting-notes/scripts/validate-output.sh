#!/bin/bash
# validate-output.sh
# Structural validation after process-meeting-notes completes.
#
# Checks:
# 1. Client files were created/modified during this session
# 2. Modified files have valid YAML frontmatter
# 3. A changelog contains an Action Item Audit receipt
# 4. A changelog contains a Results Capture receipt
#
# Skill-declared Stop hooks persist for the rest of the session once the
# skill is loaded, so this script gates itself: it only validates when a
# meeting note in Clients/**/Meeting Notes/ has been touched in the last
# ACTIVITY_WINDOW minutes. Otherwise it exits 0 silently so unrelated
# Stop events don't trigger false-positive failures.
#
# Exit 1 with a message on stderr blocks the skill from completing and
# feeds the message back to Claude, which is the whole point: a step that
# is merely documented as mandatory eventually gets skipped. This is how
# you make one actually mandatory.

read -r INPUT  # Stop event JSON from stdin

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null

ACTIVITY_WINDOW=60  # meeting-processing activity threshold (minutes)
WINDOW=120          # downstream check window (minutes)

# --- Gate: only validate when meeting-note activity is recent ---
RECENT_MEETING_NOTE=$(find Clients/ -path "*/Meeting Notes/*" -name "*.md" -mmin -${ACTIVITY_WINDOW} -type f 2>/dev/null | head -1)

if [ -z "$RECENT_MEETING_NOTE" ]; then
  exit 0
fi

ERRORS=()

# --- Check 1: Client files were modified ---
MODIFIED=$(find Clients/ -name "*.md" -mmin -${WINDOW} -type f 2>/dev/null)

if [ -z "$MODIFIED" ]; then
  ERRORS+=("MISSING CLIENT FILES: No client files were modified in the last ${WINDOW} minutes. Meeting notes may not have been processed.")
fi

# --- Check 2: Frontmatter validation ---
if [ -n "$MODIFIED" ]; then
  while IFS= read -r file; do
    if [ -n "$file" ]; then
      FIRST_LINE=$(head -1 "$file" 2>/dev/null)
      if [ "$FIRST_LINE" != "---" ]; then
        ERRORS+=("MISSING FRONTMATTER: ${file}")
      fi
    fi
  done <<< "$MODIFIED"
fi

# --- Check 3: Action Item Audit receipt in changelog ---
CHANGELOGS=$(find Clients/ -name "Linear Changelog.md" -mmin -${WINDOW} -type f 2>/dev/null)

AUDIT_FOUND=false
if [ -n "$CHANGELOGS" ]; then
  while IFS= read -r changelog; do
    if [ -n "$changelog" ] && grep -q "### Action Item Audit" "$changelog" 2>/dev/null; then
      AUDIT_FOUND=true
      break
    fi
  done <<< "$CHANGELOGS"
fi

if [ "$AUDIT_FOUND" = false ]; then
  ERRORS+=("MISSING ACTION ITEM AUDIT: No changelog contains an audit receipt. Complete Step 4.5: list every action item you committed to, cross-reference against open issues, create new issues, and write the receipt to the changelog.")
fi

# --- Check 4: Results Capture receipt in changelog ---
# Action items capture what you owe; this captures what you delivered.
# Gated because it was silently skipped for months.
RESULTS_FOUND=false
if [ -n "$CHANGELOGS" ]; then
  while IFS= read -r changelog; do
    if [ -n "$changelog" ] && grep -q "### Results Capture" "$changelog" 2>/dev/null; then
      RESULTS_FOUND=true
      break
    fi
  done <<< "$CHANGELOGS"
fi

if [ "$RESULTS_FOUND" = false ]; then
  ERRORS+=("MISSING RESULTS CAPTURE: No changelog contains a Results Capture receipt. Complete Step 4.6: sweep the transcript for metrics, shipped work, client praise (verbatim), and process outcomes; update the brand Results Tracker; write the receipt to the changelog. A quiet call is a valid finding — write the receipt with 'none'. Omitting it is not acceptable.")
fi

# --- Output ---
if [ ${#ERRORS[@]} -gt 0 ]; then
  {
    echo ""
    echo "========================================="
    echo " MEETING NOTES VALIDATION FAILED"
    echo "========================================="
    echo ""
    echo " ${#ERRORS[@]} issue(s) found:"
    echo ""
    for i in "${!ERRORS[@]}"; do
      echo " $((i+1)). ${ERRORS[$i]}"
      echo ""
    done
    echo "========================================="
    echo ""
  } >&2
  exit 1
fi

exit 0
