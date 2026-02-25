# Agent Architecture

This document describes the multi-agent topology of the `business-rules-extractor` plugin and the delegation pattern used to preserve context window budget across phases.

## Design Principle

Each agent has a **single responsibility** and a **bounded context scope**. The orchestrating command manages state; agents and skills do focused work and return results without holding onto prior context.

## Agent Topology

```
/extract-business-rule (command — orchestrator)
│
├── Phase 1: explore-feature-boundaries (skill — lightweight scan)
│   └── Runs via Task tool (subagent_type="Explore")
│   └── Returns: taxonomy only (no evidence, no rules)
│
├── Phase 2: generate-extraction-plan (skill — plan writer)
│   └── Reads: taxonomy
│   └── Writes: PLAN.md
│
└── Phase 3: extract-business-rules (skill — pipeline per document)
    ├── map-business-rule-evidence (skill — scoped evidence scan)
    ├── draft-business-rules-doc (skill — evidence-to-document synthesis)
    ├── @business-rules-reviewer (agent — validation sub-agent)
    │   └── Spawned via Task tool (subagent_type="general-purpose")
    │   └── Receives: drafted document, extraction_options, sub-feature scope, target_repo
    │   └── Performs: evidence review + structural conformance + source fact-checking (3-5 spot checks)
    │   └── Returns: pass/fail + findings + source check results
    └── Source Reference Audit (inline step after reviewer)
        └── Parses all > **Source:** references
        └── Reads actual files at referenced lines
        └── Auto-fixes relative paths, flags mismatches
```

## Delegation Rules

### When to delegate to `@business-rules-reviewer`

The `extract-business-rules` skill **must** delegate validation to `@business-rules-reviewer` rather than running `validate-business-rules-evidence` inline when:

- The drafted document exceeds 200 lines — the reviewer gets a clean context with only the document to evaluate.
- After a remediation cycle — re-validation runs in a fresh reviewer context, not the same one that produced the original findings.

Pass to the reviewer:
- The full drafted markdown document.
- The active `extraction_options` so the reviewer knows which sections are expected.
- The sub-feature scope for context.
- The `target_repo` path so the reviewer can read source files for fact-checking.

### Task tool delegation

Use the Task tool to spawn the reviewer as a subagent:

```
Task tool with subagent_type="general-purpose"
Prompt: include the full agent definition, the drafted document,
active extraction_options, sub-feature scope, and target_repo.
```

This gives the reviewer a completely clean context and enables source fact-checking (the reviewer reads files from `target_repo` to verify references).

### Why this matters

The `draft-business-rules-doc` phase consumes significant context (evidence inventory + synthesis). Delegating validation to `@business-rules-reviewer` gives the quality gate a clean view of only the output, not the intermediate evidence, resulting in more accurate findings.

The reviewer now also performs **source fact-checking**: it spot-checks 3-5 key source references by reading the actual code at the referenced file and line range. Any mismatch is a hard fail.

## Context Budget Guidelines

| Phase | Expected context consumption | Notes |
|---|---|---|
| Exploration | Low | Scan only, no full file reads |
| Plan generation | Low | Reads taxonomy, writes PLAN.md |
| Evidence mapping | Medium–High | Depends on sub-feature size |
| Document drafting | High | Evidence + synthesis |
| Validation (reviewer) | Low–Medium | Document + source spot-checks |
| Source Reference Audit | Low | Parse references + read lines |

## State Persistence

The command stores state in `state.json`. Agents and skills are **stateless** — they receive inputs, produce outputs, and do not read state.json directly. The command is responsible for reading state and passing the right inputs to each agent/skill.

## Adding New Agents

Place new agent definition files in `agents/`. An agent file should:
- Have a clear single-responsibility description in the front-matter.
- Define its expected inputs and output format.
- Not depend on global state — receive all context as explicit inputs.
