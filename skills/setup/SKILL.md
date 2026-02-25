---
name: setup
description: Collect target repo, feature scope, and model mode. Write initial state.json for a new extraction run.
---

# Setup

## Objective

Collect all required inputs for a new extraction run and write the initial `state.json`.

## Inputs

- Current workspace context (to suggest repos)
- `bre.config.json` path (plugin root — read to get available modes and default)

## Phase Block

Open and close every setup run with this block:

```
━━━ [SETUP] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Process

### Step 1 — Read bre.config.json

Read `bre.config.json` from the plugin root to determine:
- Available modes (`max-quality`, `balanced`, `budget`)
- `default_mode`
- Model assignments per phase for the selected mode

If the file is not found, fall back to `balanced` defaults:
- `explore`: haiku, `plan`: haiku, `map`: sonnet, `draft`: sonnet, `reviewer`: sonnet

### Step 2 — Collect inputs via AskQuestion

**Question 1 — Target repository** (single-select):
Present repository options from the current workspace. If only one repo is in context, confirm it rather than asking.

**Question 2 — Feature scope** (free text):
"What feature do you want to document? (e.g. Twilio Call Actions)"

**Question 3 — Extraction mode** (single-select):
Present the three modes with their descriptions from `bre.config.json`:
- `max-quality` — best models, highest accuracy, higher cost
- `balanced` — fast models for structure, Sonnet for synthesis (default)
- `budget` — Haiku everywhere except draft synthesis

### Step 3 — Derive slugs

- `feature_slug`: kebab-case from feature scope (e.g. "Twilio Call Actions" → `twilio-call-actions`)
- `repo_slug`: `basename(target_repo)` (e.g. `/Users/will/Code/ricochet-api` → `ricochet-api`)

### Step 4 — Write state.json

Write to: `<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/state.json`

```json
{
  "feature": "<feature name>",
  "feature_slug": "<kebab-case>",
  "target_repo": "<absolute repo path>",
  "repo_slug": "<basename of target repo>",
  "output_root": "<absolute output root path>",
  "phase": "exploring",
  "mode": "<selected mode>",
  "models": {
    "explore":  "<model>",
    "plan":     "<model>",
    "map":      "<model>",
    "draft":    "<model>",
    "reviewer": "<model>"
  },
  "extraction_options": {
    "business_rules": true,
    "technical_rules": false,
    "usage_context": false,
    "examples": false
  },
  "completed": [],
  "pending": [],
  "failed": []
}
```

## Output

Return the written `state.json` path and the resolved model assignments for the selected mode.
