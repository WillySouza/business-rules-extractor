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

CURSOR_DIR="${TARGET_REPO}/.cursor"

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

echo "business-rules-extractor files removed from: ${TARGET_REPO}"
