---
name: help
description: Explain the bre pipeline flow and what each skill does.
---

# Help

Display a reference guide for the `bre` (business rules extractor) plugin.

## Output

Print the following guide exactly as shown. Do not add interpretation or commentary.

---

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 [BRE] Business Rules Extractor — Reference Guide
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## What it does

`bre` extracts feature-level business rules from source code and produces structured
markdown documents — one per sub-feature. It runs as a **state machine**: each run
processes exactly one document and stops. Run it again to continue.

Every rule must be backed by code evidence. Ambiguities become explicit open questions.

---

## How to run

```
/bre:execute
```

That's it. On first run you'll be asked for target repo, feature scope, and detail level.
Subsequent runs resume from where the previous one stopped.

---

## Run flow

```
Run 1  →  Setup + Exploration + Plan review        [stops for approval]
Run 2  →  [STATUS] → document 1/N extracted → [STATUS]
Run 3  →  [STATUS] → document 2/N extracted → [STATUS]
...
Run N+1 → [STATUS FINAL]
```

---

## Phases and visual blocks

Each phase announces itself with a labeled block so you always know what's happening:

```
━━━ [SETUP]   ━━━  Collect repo, feature, model mode
━━━ [EXPLORE] ━━━  Scan feature boundaries → taxonomy of sub-features
━━━ [PLAN]    ━━━  Generate PLAN.md → user approves documents
━━━ [EXECUTE] ━━━  One sub-feature pipeline (map → draft → review → audit)
━━━ [MAP]     ━━━  Build evidence inventory from source code
━━━ [DRAFT]   ━━━  Synthesize evidence into structured document
━━━ [REVIEW]  ━━━  @business-rules-reviewer validates + fact-checks sources
━━━ [AUDIT]   ━━━  Final source reference verification before writing to disk
━━━ [COMPARE] ━━━  Multi-repo delta analysis
```

---

## Skills

| Skill | Invocation | When it runs |
|---|---|---|
| `setup` | internal | Run 1 only — collects inputs, reads bre.config.json, writes state.json |
| `explore` | internal | Run 1 — lightweight taxonomy scan (subagent: Explore) |
| `plan` | internal | Run 1 — converts taxonomy to PLAN.md for user review |
| `map` | internal | Each doc run — builds scoped evidence inventory |
| `draft` | internal | Each doc run — converts evidence to structured document |
| `validate` | internal | Inline quality gate (used when reviewer is not spawned) |
| `execute` | internal | Each doc run — orchestrates map → draft → review → audit |
| `compare` | internal | After all repos reach done — produces shared/delta comparison |
| `help` | `bre:help` | Anytime — shows this guide |

---

## Model modes

Configured in `bre.config.json` at the plugin root.

| Mode | explore | plan | map | draft | reviewer |
|---|---|---|---|---|---|
| `max-quality` | sonnet | sonnet | opus | opus | opus |
| `balanced` | haiku | haiku | sonnet | sonnet | sonnet |
| `budget` | haiku | haiku | haiku | sonnet | haiku |

Selected once during Setup and stored in `state.json`. Change by editing `bre.config.json`
or deleting `state.json` to restart the extraction.

---

## Output paths

| Artifact | Path |
|---|---|
| Documents | `<output-root>/<repo-slug>/business-rules/<feature-slug>/<doc>.md` |
| State | `<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/state.json` |
| Plan | `<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/PLAN.md` |

`<output-root>` defaults to `<target-repo>/docs`.

---

## Agent topology

```
/bre:execute (command — orchestrator)
│
├── setup       (skill — inputs + state.json)
├── explore     (skill — taxonomy scan, subagent: Explore)
├── plan        (skill — PLAN.md generation)
└── execute     (skill — per-document pipeline)
    ├── map     (skill — evidence inventory)
    ├── draft   (skill — document synthesis)
    └── @business-rules-reviewer  (agent — validation + source fact-checking)
```

---

## Multi-repo compare

```
/bre:execute → select multi_repo_compare mode
```

Runs Phases 0–3 per repo, then runs `compare` to produce:
shared rules, repo-specific rules, behavior drift/gaps, migration risks.

---

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Run /bre:execute to start. Run /bre:help anytime.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
