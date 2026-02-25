#!/usr/bin/env bash
set -euo pipefail

TARGET_REPO="${1:-}"

if [[ -z "${TARGET_REPO}" ]]; then
  echo "Usage: ./scripts/uninstall-local.sh /absolute/path/to/target-repo"
  exit 1
fi

if [[ ! -d "${TARGET_REPO}" ]]; then
  echo "Target repository not found: ${TARGET_REPO}"
  exit 1
fi

CLAUDE_DIR="${TARGET_REPO}/.claude"

rm -f "${CLAUDE_DIR}/commands/extract-business-rules.md"
rm -f "${CLAUDE_DIR}/commands/extract-business-rule.md"
rm -f "${CLAUDE_DIR}/commands/gen-business-rules.md"

rm -rf "${CLAUDE_DIR}/skills/extract-business-rules"
rm -rf "${CLAUDE_DIR}/skills/map-business-rule-evidence"
rm -rf "${CLAUDE_DIR}/skills/draft-business-rules-doc"
rm -rf "${CLAUDE_DIR}/skills/validate-business-rules-evidence"
rm -rf "${CLAUDE_DIR}/skills/compare-business-rules-across-repos"
rm -rf "${CLAUDE_DIR}/skills/create-business-rule"
rm -rf "${CLAUDE_DIR}/skills/explore-feature-boundaries"
rm -rf "${CLAUDE_DIR}/skills/generate-extraction-plan"

rm -f "${CLAUDE_DIR}/agents/business-rules-reviewer.md"
rm -f "${CLAUDE_DIR}/templates/base-business-rules.md"
rm -f "${CLAUDE_DIR}/templates/extraction-plan-template.md"

echo "business-rules-extractor files removed from: ${TARGET_REPO}"
