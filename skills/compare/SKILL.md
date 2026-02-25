---
name: compare
description: Compare extracted business rules from multiple repositories and produce migration-oriented shared/delta outputs.
---

# Compare Business Rules Across Repositories

## Objective

Produce a migration-ready comparison between repositories for the same feature.

## Inputs

- Repository A extraction artifacts (evidence and/or draft doc)
- Repository B extraction artifacts (evidence and/or draft doc)
- Feature scope
- Comparison output path (optional)

## Comparison Sections (required)

1. Shared Rules
2. Legacy-only Rules (Repository A only)
3. New API-only Rules (Repository B only)
4. Behavior Drift / Gaps (differences that change user outcomes)
5. Migration Risks and Open Questions

## Rules

- Do not merge conflicting rules into a single generalized statement.
- Every compared rule must keep repository attribution.
- Mark confidence per compared rule (`high`, `medium`, `low`).
- If evidence is incomplete on either side, move claim to `Open Questions`.

## Output

Return a comparison document with:

- explicit per-repo attribution
- shared vs delta breakdown
- migration-focused risk summary

## Phase Block

Open your output with:

```
━━━ [COMPARE] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Feature: <feature scope>
  Repos: <repo-a> ↔ <repo-b>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
