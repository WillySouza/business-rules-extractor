#!/usr/bin/env bash
set -euo pipefail

TARGET_REPO="${1:-}"
PLATFORM="${2:-cursor}"

if [[ -z "${TARGET_REPO}" ]]; then
  echo "Usage: ./scripts/uninstall-local.sh /absolute/path/to/target-repo [cursor|claude-code]"
  exit 1
fi

if [[ ! -d "${TARGET_REPO}" ]]; then
  echo "Target repository not found: ${TARGET_REPO}"
  exit 1
fi

if [[ ! "${PLATFORM}" =~ ^(cursor|claude-code)$ ]]; then
  echo "Invalid platform: ${PLATFORM}"
  echo "Expected one of: cursor, claude-code"
  exit 1
fi

uninstall_cursor() {
  local CURSOR_DIR="${TARGET_REPO}/.cursor"

  rm -f "${CURSOR_DIR}/commands/extract-business-rules.md"
  rm -f "${CURSOR_DIR}/commands/extract-business-rule.md"
  rm -f "${CURSOR_DIR}/commands/gen-business-rules.md"

  rm -rf "${CURSOR_DIR}/skills/extract-business-rules"
  rm -rf "${CURSOR_DIR}/skills/map-business-rule-evidence"
  rm -rf "${CURSOR_DIR}/skills/draft-business-rules-doc"
  rm -rf "${CURSOR_DIR}/skills/validate-business-rules-evidence"
  rm -rf "${CURSOR_DIR}/skills/compare-business-rules-across-repos"
  rm -rf "${CURSOR_DIR}/skills/create-business-rule"
  rm -rf "${CURSOR_DIR}/skills/explore-feature-boundaries"
  rm -rf "${CURSOR_DIR}/skills/generate-extraction-plan"

  rm -f "${CURSOR_DIR}/rules/business-rules-evidence-quality.mdc"
  rm -f "${CURSOR_DIR}/agents/business-rules-reviewer.md"
  rm -f "${CURSOR_DIR}/templates/base-business-rules.md"
  rm -f "${CURSOR_DIR}/templates/extraction-plan-template.md"
}

uninstall_claude_code() {
  local CLAUDE_DIR="${TARGET_REPO}/.claude"

  rm -f "${CLAUDE_DIR}/commands/extract-business-rules.md"
  rm -f "${CLAUDE_DIR}/commands/extract-business-rule.md"
  rm -f "${CLAUDE_DIR}/commands/gen-business-rules.md"
}

case "${PLATFORM}" in
  cursor)      uninstall_cursor ;;
  claude-code) uninstall_claude_code ;;
esac

echo "business-rules-extractor files removed from: ${TARGET_REPO} (${PLATFORM})"
