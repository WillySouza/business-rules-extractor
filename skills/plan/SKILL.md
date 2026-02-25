---
name: plan
description: Generate a PLAN.md from a feature taxonomy, proposing document groupings for user review before extraction begins.
---

# Generate Extraction Plan

## Objective

Convert a feature taxonomy into a `PLAN.md` that the user can review before any extraction runs. The plan is the single source of truth for what documents will be generated.

## Inputs

- Feature name
- Target repository path
- Taxonomy from `explore`
- Extraction options (which sections to include)

## Output: PLAN.md

Write the plan to:
`<target-repo>/docs/business-rules/extractions/<feature-slug>/PLAN.md`

Use the following format:

```md
# Extraction Plan: <Feature Name>

**Repository:** `<repo-path>`
**Feature slug:** `<feature-slug>`
**Created:** `<YYYY-MM-DD>`

## Extraction Options

- [x] Business Rules — validation, conditions, state transitions
- [ ] Technical Rules — API contracts, error handling, integration patterns
- [ ] Usage Context — triggers, pre/post conditions, user workflows
- [ ] Examples — concrete scenarios with payloads and state transitions

## Proposed Documents

| # | Document | Sub-feature | Entrypoints | Key Files |
|---|----------|-------------|-------------|-----------|
| 1 | `<slug>.md` | <sub-feature name> | `Controller@method` | `path/to/file.php` |
| 2 | ... | ... | ... | ... |

## Grouping Notes

- <rationale for any non-obvious grouping>
- <ambiguity flagged, if any>

---
> To remove a document from the plan, delete or comment out its row before approving.
> Document order determines execution order.
```

## Rules

- List documents in logical execution sequence (initiation before termination, happy path before error paths).
- Do not generate more than 10 rows. If taxonomy has more, group the least distinct sub-features.
- Flag any grouping that required a judgment call in the Grouping Notes section.
- Extraction options checkboxes must reflect the choices collected in Phase 0.

## Phase Block

Open your output with:

```
━━━ [PLAN] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Feature: <feature scope>
  Proposed documents: <N>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
