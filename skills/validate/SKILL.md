---
name: validate
description: Validate business rule drafts for evidence coverage, confidence tagging, and unresolved ambiguity.
---

# Validate Business Rules Evidence

## Objective

Run a strict quality gate on a drafted business-rules markdown document.

## Validation Checklist

### Evidence & Content Quality

- Every business rule is supported by at least one evidence item.
- No unsupported behavioral claims appear in rule sections.
- Every rule includes a confidence label (`high`, `medium`, `low`).
- `Open Questions` contains only unresolved ambiguity.
- `Decision Log` captures resolved answers from `AskQuestion`.
- Technical trace covers both synchronous and asynchronous behavior when relevant.
- Primary rules do not include out-of-scope domains.
- Cross-domain content follows policy (`reference_only` by default).
- Product-mode output avoids low-level implementation details in core rule text.
- For `depth=full`, each in-scope entrypoint has documented downstream lifecycle coverage.
- If `webhook`/`outbound-callback` are in-scope, they appear explicitly in `Rule Details` with post-endpoint flow behavior.
- In `multi_repo_compare`, each compared rule has explicit repository attribution.
- In `multi_repo_compare`, shared rules and drift/gaps are separated clearly.

### Structural Conformance

- Required H2 headings are present and in the correct order:
  1. `## Feature Metadata` (always)
  2. `## Business Rule Summary` (always)
  3. `## Rule Details` (if `business_rules` active)
  4. `## Technical Trace` (if `technical_rules` active)
  5. `## Dependencies and Impact` (if `technical_rules` active)
  6. `## Usage Context` (if `usage_context` active)
  7. `## Concrete Examples` (if `examples` active)
  8. `## Evidence Map` (always)
  9. `## Assumptions` (if `business_rules` active)
  10. `## Open Questions (Human-in-the-loop)` (if `business_rules` active)
  11. `## Decision Log` (if `business_rules` active)
- Feature Metadata contains all required fields: Feature Name, Sub-feature, Domain, Source Repo, Last Updated.
- Rule Details entries use `### Rule N - <title>` format with all required fields (Business Intent, Trigger, Conditions, Outcome, Exceptions, Confidence).
- No numbered section headings (e.g. `## 1. API Endpoint` is forbidden — use plain `## Section Name`).
- Sections for inactive `extraction_options` are completely absent (not empty).

### Source Reference Format

- All `> **Source:**` references use absolute paths (path component starts with `/`).
- Display text uses `Filename.ext:N-M` format (filename + line range).
- Link target uses `#LN-LM` anchor format for line ranges or `#LN` for single lines.
- Source references are placed as blockquotes after code blocks, not as inline comments.

## Failure Handling

If failures are found:

1. List each issue with a precise fix recommendation.
2. Mark unsupported statements for removal or downgrade to assumptions.
3. Require follow-up `AskQuestion` when ambiguity blocks confidence.
4. Flag scope leakage and move leaked content to dependency references or follow-up extraction notes.
5. Flag shallow coverage when depth is full and require endpoint-chain expansion before pass.

## Output

Return:

- pass/fail status
- issue list (if any)
- minimal remediation actions

## Phase Block

Open your output with:

```
━━━ [VALIDATE] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Sub-feature: <sub-feature scope>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
