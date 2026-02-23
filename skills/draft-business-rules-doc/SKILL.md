---
name: draft-business-rules-doc
description: Draft a business rules markdown document from mapped evidence using the base template.
---

# Draft Business Rules Document

## Objective

Convert mapped evidence into a feature-level business rules document without adding unsupported claims.

## Inputs

- Mode (`single_repo` or `multi_repo_compare`)
- Mapped evidence inventory
- Target repository path
- Feature scope (sub-feature name for scoped extractions)
- Output path
- Template: `templates/base-business-rules.md`
- `depth` (default `full`)
- `product_mode` (default `true`)
- `cross_domain_policy` (default `reference_only`)
- `extraction_options` (controls which sections are generated):
  - `business_rules` (default `true`): Rule Details, Assumptions, Open Questions, Decision Log
  - `technical_rules` (default `false`): Technical Trace, Dependencies and Impact
  - `usage_context` (default `false`): Usage Context section
  - `examples` (default `false`): Concrete Examples section

## Rules

- Use only mapped evidence as factual support.
- If evidence is missing, move text to `Assumptions` or `Open Questions`.
- Keep primary rule text in product language when `product_mode=true`.
- Do not include implementation references in summary/rule text; keep code references in `Evidence Map`.
- Assign confidence per rule:
  - `high`: explicitly proven by code paths
  - `medium`: partial support or indirect evidence
  - `low`: ambiguity or missing coverage

## Document Requirements

Always include regardless of `extraction_options`:

- Feature Metadata
- Business Rule Summary
- Evidence Map

Include only sections corresponding to active `extraction_options`:

| Option | Sections generated |
|---|---|
| `business_rules` | Rule Details, Assumptions, Open Questions, Decision Log |
| `technical_rules` | Technical Trace, Dependencies and Impact |
| `usage_context` | Usage Context (trigger, pre/post conditions, entry paths) |
| `examples` | Concrete Examples (scenarios with payloads and state transitions) |

Omit sections for inactive options entirely — do not include empty placeholders.

For `depth=full`, add explicit entrypoint-lifecycle coverage:

- include at least one rule or subsection per in-scope entrypoint
- explain what happens after each entrypoint through downstream handlers
- include terminal outcomes and side effects for each entrypoint chain

If callback endpoints are in-scope (for example `webhook`, `outbound-callback`), they must be explicitly documented in primary rule details (not only technical trace).

Cross-domain handling:

- If `cross_domain_policy=reference_only`, do not expand cross-domain rules in `Rule Details`.
- Mention cross-domain links as dependencies in `Dependencies and Impact`.
- Optionally list unresolved adjacent-domain gaps in `Open Questions`.

## Output

Produce a draft markdown ready for quality validation.

If mode is `multi_repo_compare`, output structure must include:

- Shared Rules
- Legacy-only Rules
- New API-only Rules
- Behavior Drift / Gaps
- Migration Risks
