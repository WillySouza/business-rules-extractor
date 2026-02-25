#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TARGET_REPO="${1:-}"
OUTPUT_ROOT="${2:-${TARGET_REPO}/docs}"

if [[ -z "${TARGET_REPO}" ]]; then
  echo "Usage: ./scripts/install-local.sh /absolute/path/to/target-repo [/output/root]"
  echo ""
  echo "Copies all plugin components into the target repo's .claude/ directory."
  echo "Prefer the plugin approach instead: add this repo to Claude Code's plugin config."
  exit 1
fi

if [[ ! -d "${TARGET_REPO}" ]]; then
  echo "Target repository not found: ${TARGET_REPO}"
  exit 1
fi

patch_output_root() {
  local cmd_file="$1"
  sed -i '' "s|<output-root>|${OUTPUT_ROOT}|g" "${cmd_file}"
}

CLAUDE_DIR="${TARGET_REPO}/.claude"
mkdir -p "${CLAUDE_DIR}/commands" "${CLAUDE_DIR}/skills" "${CLAUDE_DIR}/agents" "${CLAUDE_DIR}/templates"

# Remove legacy command variants and keep a single command name.
rm -f "${CLAUDE_DIR}/commands/extract-business-rules.md"
rm -f "${CLAUDE_DIR}/commands/gen-business-rules.md"
cp -f "${PLUGIN_ROOT}/commands/extract-business-rule.md" "${CLAUDE_DIR}/commands/extract-business-rule.md"
patch_output_root "${CLAUDE_DIR}/commands/extract-business-rule.md"

rm -rf "${CLAUDE_DIR}/skills/extract-business-rules"
rm -rf "${CLAUDE_DIR}/skills/map-business-rule-evidence"
rm -rf "${CLAUDE_DIR}/skills/draft-business-rules-doc"
rm -rf "${CLAUDE_DIR}/skills/validate-business-rules-evidence"
rm -rf "${CLAUDE_DIR}/skills/compare-business-rules-across-repos"
rm -rf "${CLAUDE_DIR}/skills/create-business-rule"
rm -rf "${CLAUDE_DIR}/skills/explore-feature-boundaries"
rm -rf "${CLAUDE_DIR}/skills/generate-extraction-plan"

cp -R "${PLUGIN_ROOT}/skills/extract-business-rules" "${CLAUDE_DIR}/skills/extract-business-rules"
cp -R "${PLUGIN_ROOT}/skills/map-business-rule-evidence" "${CLAUDE_DIR}/skills/map-business-rule-evidence"
cp -R "${PLUGIN_ROOT}/skills/draft-business-rules-doc" "${CLAUDE_DIR}/skills/draft-business-rules-doc"
cp -R "${PLUGIN_ROOT}/skills/validate-business-rules-evidence" "${CLAUDE_DIR}/skills/validate-business-rules-evidence"
cp -R "${PLUGIN_ROOT}/skills/compare-business-rules-across-repos" "${CLAUDE_DIR}/skills/compare-business-rules-across-repos"
cp -R "${PLUGIN_ROOT}/skills/create-business-rule" "${CLAUDE_DIR}/skills/create-business-rule"
cp -R "${PLUGIN_ROOT}/skills/explore-feature-boundaries" "${CLAUDE_DIR}/skills/explore-feature-boundaries"
cp -R "${PLUGIN_ROOT}/skills/generate-extraction-plan" "${CLAUDE_DIR}/skills/generate-extraction-plan"

cp -f "${PLUGIN_ROOT}/agents/business-rules-reviewer.md" "${CLAUDE_DIR}/agents/business-rules-reviewer.md"
cp -f "${PLUGIN_ROOT}/templates/base-business-rules.md" "${CLAUDE_DIR}/templates/base-business-rules.md"
cp -f "${PLUGIN_ROOT}/templates/extraction-plan-template.md" "${CLAUDE_DIR}/templates/extraction-plan-template.md"

echo ""
echo "business-rules-extractor installed in: ${TARGET_REPO}"
echo "Next step: run /extract-business-rule in Claude Code"
