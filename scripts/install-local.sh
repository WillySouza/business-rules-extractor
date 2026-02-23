#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TARGET_REPO="${1:-}"
PLATFORM="${2:-cursor}"
OUTPUT_ROOT="${3:-${TARGET_REPO}/docs}"

if [[ -z "${TARGET_REPO}" ]]; then
  echo "Usage: ./scripts/install-local.sh /absolute/path/to/target-repo [cursor|claude-code] [/output/root]"
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

patch_output_root() {
  local cmd_file="$1"
  # Replace placeholder with the configured output root using | as delimiter
  sed -i '' "s|<output-root>|${OUTPUT_ROOT}|g" "${cmd_file}"
}

install_cursor() {
  local CURSOR_DIR="${TARGET_REPO}/.cursor"
  mkdir -p "${CURSOR_DIR}/commands" "${CURSOR_DIR}/skills" "${CURSOR_DIR}/rules" "${CURSOR_DIR}/agents" "${CURSOR_DIR}/templates"

  # Remove legacy command variants and keep a single command name.
  rm -f "${CURSOR_DIR}/commands/extract-business-rules.md"
  rm -f "${CURSOR_DIR}/commands/gen-business-rules.md"
  cp -f "${PLUGIN_ROOT}/commands/extract-business-rule.md" "${CURSOR_DIR}/commands/extract-business-rule.md"
  patch_output_root "${CURSOR_DIR}/commands/extract-business-rule.md"

  rm -rf "${CURSOR_DIR}/skills/extract-business-rules"
  rm -rf "${CURSOR_DIR}/skills/map-business-rule-evidence"
  rm -rf "${CURSOR_DIR}/skills/draft-business-rules-doc"
  rm -rf "${CURSOR_DIR}/skills/validate-business-rules-evidence"
  rm -rf "${CURSOR_DIR}/skills/compare-business-rules-across-repos"
  rm -rf "${CURSOR_DIR}/skills/create-business-rule"
  rm -rf "${CURSOR_DIR}/skills/explore-feature-boundaries"
  rm -rf "${CURSOR_DIR}/skills/generate-extraction-plan"

  cp -R "${PLUGIN_ROOT}/skills/extract-business-rules" "${CURSOR_DIR}/skills/extract-business-rules"
  cp -R "${PLUGIN_ROOT}/skills/map-business-rule-evidence" "${CURSOR_DIR}/skills/map-business-rule-evidence"
  cp -R "${PLUGIN_ROOT}/skills/draft-business-rules-doc" "${CURSOR_DIR}/skills/draft-business-rules-doc"
  cp -R "${PLUGIN_ROOT}/skills/validate-business-rules-evidence" "${CURSOR_DIR}/skills/validate-business-rules-evidence"
  cp -R "${PLUGIN_ROOT}/skills/compare-business-rules-across-repos" "${CURSOR_DIR}/skills/compare-business-rules-across-repos"
  cp -R "${PLUGIN_ROOT}/skills/create-business-rule" "${CURSOR_DIR}/skills/create-business-rule"
  cp -R "${PLUGIN_ROOT}/skills/explore-feature-boundaries" "${CURSOR_DIR}/skills/explore-feature-boundaries"
  cp -R "${PLUGIN_ROOT}/skills/generate-extraction-plan" "${CURSOR_DIR}/skills/generate-extraction-plan"

  cp -f "${PLUGIN_ROOT}/rules/business-rules-evidence-quality.mdc" "${CURSOR_DIR}/rules/business-rules-evidence-quality.mdc"
  cp -f "${PLUGIN_ROOT}/agents/business-rules-reviewer.md" "${CURSOR_DIR}/agents/business-rules-reviewer.md"
  cp -f "${PLUGIN_ROOT}/templates/base-business-rules.md" "${CURSOR_DIR}/templates/base-business-rules.md"
  cp -f "${PLUGIN_ROOT}/templates/extraction-plan-template.md" "${CURSOR_DIR}/templates/extraction-plan-template.md"

  echo ""
  echo "business-rules-extractor installed in: ${TARGET_REPO}"
  echo "Next step: reload Cursor window and run /extract-business-rule"
}

install_claude_code() {
  local CLAUDE_DIR="${TARGET_REPO}/.claude"
  mkdir -p "${CLAUDE_DIR}/commands"

  # Remove old command if present
  rm -f "${CLAUDE_DIR}/commands/extract-business-rules.md"
  rm -f "${CLAUDE_DIR}/commands/gen-business-rules.md"
  cp -f "${PLUGIN_ROOT}/commands/extract-business-rule.md" "${CLAUDE_DIR}/commands/extract-business-rule.md"
  patch_output_root "${CLAUDE_DIR}/commands/extract-business-rule.md"

  echo ""
  echo "business-rules-extractor installed in: ${TARGET_REPO}"
  echo "Next step: run /extract-business-rule in Claude Code"
}

case "${PLATFORM}" in
  cursor)     install_cursor ;;
  claude-code) install_claude_code ;;
esac
