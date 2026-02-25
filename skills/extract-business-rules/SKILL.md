---
name: extract-business-rules
description: Full extraction pipeline for a single sub-feature document. Maps evidence, drafts, validates, and returns the final markdown.
---

# Extract Business Rules

## Overview

Run the full evidence-first pipeline for **one sub-feature** and produce a single output document. This skill is called once per document by the `extract-business-rule` command state machine.

## Inputs

- Target repository path (`target_repo`)
- Sub-feature scope (specific, not broad — e.g. "Hold Call" not "Twilio Call Actions")
- Sub-feature entrypoints (from PLAN.md row)
- Sub-feature key files (from PLAN.md row)
- Output file path
- `extraction_options`: `{ business_rules, technical_rules, usage_context, examples }`
- `depth` (default `full`)
- `product_mode` (default `true`)
- `cross_domain_policy` (default `reference_only`)

## Pipeline

1. **Map evidence** — run `map-business-rule-evidence` scoped strictly to the sub-feature entrypoints and key files. Do not expand scope to adjacent sub-features.
   - For sub-features with >5 key files, consider grouping files and mapping evidence in parallel batches using the Task tool (optional optimization).

2. **Draft document** — run `draft-business-rules-doc` with mapped evidence and `extraction_options`. Generate only the sections corresponding to active options.

3. **Validate** — delegate to `@business-rules-reviewer` agent using the Task tool:
     ```
     Task tool with subagent_type="general-purpose"
     Prompt: include the full agent definition from agents/business-rules-reviewer.md,
     the drafted document, active extraction_options, sub-feature scope, and target_repo.
     ```
   - Pass to the reviewer:
     - The full drafted markdown document.
     - The active `extraction_options` (so the reviewer knows which sections are expected).
     - The sub-feature scope for context.
     - The `target_repo` path (so the reviewer can read source files for fact-checking).
   Do **not** run validation inline — the reviewer gets a clean context free of evidence mapping noise.

3.5. **Source Reference Audit** — after receiving the reviewer verdict, parse all `> **Source:**` references in the document and perform a systematic check:
   - Extract every source reference (path + line range).
   - For each reference, read the file at the specified lines.
   - Verify the referenced code matches the claim made in the document.
   - Auto-fix any relative paths by prepending `target_repo`.
   - Flag mismatches between referenced code and document claims.
   - If >30% of references fail verification, trigger a remediation cycle: re-read the actual code and correct the document claims or references.

4. **Remediate** — if reviewer returns `fail` or source audit finds issues:
   - Apply all automatic fixes (remove unsupported claims, downgrade to assumptions, fix relative paths).
   - If ambiguity requires human input, use `AskQuestion` before re-validating.
   - Delegate to `@business-rules-reviewer` again for re-validation. Maximum one remediation cycle.

5. **Return** — return the final markdown content ready to be written to disk.

## Quality Gate (pass criteria)

- No unsupported behavioral claims.
- Every rule has a confidence label.
- Evidence map backs all assertions.
- Technical Trace (if included) covers sync and async behavior.
- No out-of-scope sub-feature content in primary rules.
- Each in-scope entrypoint has documented downstream lifecycle coverage.
- Document follows required structural format (section order, heading format, required fields).
- All source references use absolute paths and verified line ranges.

## Failure

If the pipeline cannot produce a passing document after one remediation cycle, return:

```
FAILED: <sub-feature>
Reason: <specific gap or unresolvable ambiguity>
Recommendation: <what human action is needed>
```

Do not write a partial document to disk.

## Language

Final document in English unless user explicitly requested otherwise.
