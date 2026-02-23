# business-rules-extractor

Cursor plugin to extract feature-level business rules from source code using an evidence-first, stateful, multi-agent workflow.

Designed for **broad features** (e.g. "Twilio Call Actions") that span multiple sub-features — each sub-feature gets its own focused document, extracted in a dedicated context window.

## Install

From this plugin folder:

```bash
chmod +x scripts/install-local.sh scripts/uninstall-local.sh
./scripts/install-local.sh /absolute/path/to/target-repo
```

Then:

1. Open target repo in Cursor.
2. Reload window (`Developer: Reload Window`).
3. Run `/extract-business-rule`.

To remove:

```bash
./scripts/uninstall-local.sh /absolute/path/to/target-repo
```

## How it works

The command runs as a **state machine**: each run processes exactly one document and stops. Run it again to process the next. The state persists in `state.json` — if the context resets, the next run resumes where it stopped.

### Run flow

```
Run 1  →  Setup (questions) + Exploration + Plan review
Run 2  →  [STATUS] → document 1/N extracted → [STATUS]
Run 3  →  [STATUS] → document 2/N extracted → [STATUS]
...
Run N+1 → [STATUS FINAL ✅]
```

### What you'll be asked (Run 1 only)

1. **Target repository** — which repo to extract from.
2. **Feature scope** — what feature to document (e.g. "Twilio Call Actions").
3. **What to extract** (multi-select):
   - Business Rules — validation, conditions, state transitions
   - Technical Rules — API contracts, error handling, integration patterns
   - Usage Context — triggers, pre/post conditions, user workflows
   - Examples — concrete scenarios with payloads and state transitions
4. **Plan review** — confirm or remove proposed documents before extraction begins.

### Status panel

Every run opens and closes with a status panel:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Extraction: Twilio Call Actions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ initiate-call.md
  ✓ hold-call.md
  → mute-call.md  (3/6)
    transfer-call.md
    hangup-call.md
    record-call.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Output paths

| Artifact | Path |
|---|---|
| Documents | `<repo>/docs/business-rules/<feature-slug>/<doc>.md` |
| State | `<repo>/docs/business-rules/extractions/<feature-slug>/state.json` |
| Plan | `<repo>/docs/business-rules/extractions/<feature-slug>/PLAN.md` |

## What it includes

- **Command:** `/extract-business-rule`
- **Skills:**
  - `explore-feature-boundaries` — lightweight taxonomy scan
  - `generate-extraction-plan` — produces PLAN.md for review
  - `extract-business-rules` — full pipeline for one sub-feature
  - `map-business-rule-evidence` — scoped evidence inventory
  - `draft-business-rules-doc` — evidence-to-document synthesis
  - `validate-business-rules-evidence` — quality gate
  - `compare-business-rules-across-repos` — multi-repo comparison
- **Agent:** `business-rules-reviewer` — isolated validation sub-agent
- **Rule:** `business-rules-evidence-quality`
- **Templates:** `base-business-rules.md`, `extraction-plan-template.md`
- **Docs:** `AGENTS.md` — agent topology and delegation rules

## Multi-repo compare mode

Use when a feature spans two repositories (e.g. migration analysis).

```
/extract-business-rule → select multi_repo_compare mode
```

Output includes: shared rules, repo-specific rules, behavior drift/gaps, migration risks.

## Principles

- Every rule must have code evidence.
- Ambiguities are explicit — converted to questions or open items.
- Confidence levels are required on every rule (`high`, `medium`, `low`).
- Final documents are written in English unless explicitly requested otherwise.
- One document per context window — depth over breadth.
