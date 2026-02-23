---
name: validate-business-rules-evidence
description: Validate business rule drafts for evidence coverage, confidence tagging, and unresolved ambiguity.
---

# Validate Business Rules Evidence

## Objective

Run a strict quality gate on a drafted business-rules markdown document.

## Validation Checklist

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
