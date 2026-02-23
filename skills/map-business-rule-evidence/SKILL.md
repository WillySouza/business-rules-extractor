---
name: map-business-rule-evidence
description: Deterministically map feature-relevant business rule evidence from source code.
---

# Map Business Rule Evidence

## Objective

Build an evidence inventory for a feature. Focus on observable behavior, not naming assumptions.

## Inputs

- Target repository path
- Repository label (for multi-repo comparisons, e.g. `legacy`, `new-api`)
- Feature scope
- In-scope subdomains
- Out-of-scope subdomains
- `depth` (default `full`)
- `cross_domain_policy` (default `reference_only`)

## Mapping Scope

Start from feature entrypoints and expand to related files:

- controllers
- actions/services/use-cases
- requests/validators/policies
- repositories/models
- jobs/events/queues
- enums/resources
- feature and unit tests related to the feature

For `depth=full`, map complete entrypoint chains:

- identify all entrypoints in scope
- traverse immediate handlers/actions
- traverse downstream state transitions and side effects
- traverse terminal outcomes and completion paths

Carrier lifecycle rule:

- When feature scope includes outbound/inbound call lifecycle on Twilio/Telnyx, treat `webhook` and callback endpoints (including `outbound-callback`) as required candidate entrypoints unless explicitly marked out-of-scope.

## Evidence Record Format

Each item must include:

- `path`
- symbol/context anchor
- short reason the evidence supports a rule
- repository label
- domain tag (`core` or specific adjacent domain)
- scope tag (`in_scope`, `out_of_scope`, `cross_domain`)

## Priority

Prioritize:

- branching conditions
- validation constraints
- state transitions
- side effects (database, queues, external APIs)
- authorization decisions

De-prioritize:

- boilerplate constructors
- generic logging
- trivial plumbing

## Output

Return a concise inventory that can be consumed by synthesis without additional interpretation.

Rules for scope boundaries:

- Include full details only for `in_scope` evidence.
- Exclude `out_of_scope` evidence from primary rule candidates.
- For `cross_domain` evidence, keep only reference metadata if `cross_domain_policy=reference_only`.
- For `depth=full`, do not finalize evidence inventory if an in-scope entrypoint has no mapped downstream chain.
