---
name: execute
description: Full extraction pipeline for a single sub-feature document. Maps evidence, drafts, validates, and returns the final markdown.
---

# Execute

## Overview

Run the full evidence-first pipeline for **one sub-feature** and produce a single output document. Called once per document by the `execute` command state machine.

## Inputs

- `target_repo` — absolute path to the target repository
- Sub-feature scope (specific, e.g. "Hold Call" not "Twilio Call Actions")
- Sub-feature entrypoints (from PLAN.md row)
- Sub-feature key files (from PLAN.md row)
- Output file path
- `extraction_options`: `{ business_rules, technical_rules, usage_context, examples }`
- `models`: `{ map, draft, reviewer }` — from state.json
- `depth` (default `full`)
- `product_mode` (default `true`)
- `cross_domain_policy` (default `reference_only`)

## Pipeline

### Step 1 — Map evidence

```
━━━ [MAP] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Sub-feature: <sub-feature>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Run the `map` skill scoped strictly to the sub-feature entrypoints and key files. Do not expand scope to adjacent sub-features.

For sub-features with >5 key files, consider mapping evidence in parallel Task batches (optional optimization).

Use model: `models.map`

### Step 2 — Draft document

```
━━━ [DRAFT] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Sub-feature: <sub-feature>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Run the `draft` skill with mapped evidence and `extraction_options`. Generate only the sections corresponding to active options.

Use model: `models.draft`

### Step 3 — Validate

```
━━━ [REVIEW] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Delegating to @business-rules-reviewer...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Delegate to `@business-rules-reviewer` via the Task tool:
```
Task tool
  subagent_type: "general-purpose"
  model: <models.reviewer>
  prompt: include full agent definition from agents/business-rules-reviewer.md,
          the drafted document, active extraction_options,
          sub-feature scope, and target_repo.
```

Do **not** run validation inline — the reviewer gets a clean context free of evidence mapping noise.

### Step 3.5 — Source Reference Audit

```
━━━ [AUDIT] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Verifying source references...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After receiving the reviewer verdict:
- Extract every `> **Source:**` reference (path + line range).
- Read each file at the specified lines.
- Verify the referenced code matches the claim in the document.
- Auto-fix relative paths by prepending `target_repo`.
- Flag mismatches between referenced code and document claims.
- If >30% of references fail: trigger a remediation cycle — re-read actual code and correct claims or references.

### Step 4 — Remediate (if needed)

If reviewer returns `fail` or source audit finds issues:
- Apply all automatic fixes (remove unsupported claims, downgrade to assumptions, fix paths).
- If ambiguity requires human input, use `AskQuestion` before re-validating.
- Delegate to `@business-rules-reviewer` again. Maximum one remediation cycle.

### Step 5 — Return

Return the final markdown content ready to be written to disk.

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
