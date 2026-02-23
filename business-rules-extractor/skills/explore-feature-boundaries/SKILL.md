---
name: explore-feature-boundaries
description: Lightweight taxonomy scan of a broad feature to identify natural sub-features and their associated entrypoints.
---

# Explore Feature Boundaries

## Objective

Produce a taxonomy of sub-features for a given feature scope. This is a **lightweight scan** — the goal is to identify and group, not to extract full evidence. Do not read full file contents unless strictly necessary to determine grouping.

## Inputs

- Target repository path
- Feature scope (broad feature name, e.g. "Twilio Call Actions")

## Process

1. Search for all entrypoints related to the feature scope:
   - HTTP routes / controllers
   - Console commands
   - Jobs / Listeners / Event handlers
   - Webhooks / callbacks
2. For each entrypoint, identify the immediate action or service it delegates to.
3. Group entrypoints into natural sub-features using these signals:
   - Same lifecycle stage → same group
   - Distinct trigger + distinct state machine → separate group
   - Significantly different conditions or side effects → separate group
   - Actions that differ only in one parameter (e.g. mute vs unmute) → can share a group
4. For each group, produce a taxonomy entry.

## Grouping Heuristics

- Prefer separate documents for sub-features with distinct triggers and outcomes.
- Group actions that always operate on the same object lifecycle and share the same state machine.
- If a group would exceed 5 key files, recommend splitting.
- Order groups by natural execution sequence (initiation before termination).
- Maximum recommended groups: 10. If more are found, flag for user review.

## Output Format

Return a structured taxonomy only. Do not include evidence or rule text.

```
Taxonomy: <Feature Name>
Total sub-features found: N

Sub-feature 1
  slug:         <kebab-case-name>
  description:  <one-line business description>
  entrypoints:  [list of controller@method or route]
  key files:    [list of relevant file paths]

Sub-feature 2
  ...
```

Flag any sub-feature where grouping decision was non-obvious with a `[grouped: <reason>]` annotation.
