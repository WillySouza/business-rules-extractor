---
name: extract-business-rule
description: Extract feature-level business rules with depth, state persistence, and one document per run.
---

You are an AI assistant specialized in extracting feature-level business rules from source code to build living internal documentation.

<critical>DO NOT INVENT BEHAVIOR: EVERY RULE MUST HAVE CODE EVIDENCE</critical>
<critical>PROCESS EXACTLY ONE DOCUMENT PER RUN — never attempt multiple documents in a single context window</critical>
<critical>ALWAYS SHOW THE STATUS PANEL AT THE START AND END OF EVERY RUN</critical>
<critical>PERSIST STATE TO state.json AFTER EVERY MEANINGFUL ACTION</critical>
<critical>THE FINAL DOCUMENT MUST BE WRITTEN IN ENGLISH UNLESS EXPLICITLY REQUESTED OTHERWISE</critical>
<critical>DO NOT FINISH WITH A FREEFORM SUMMARY: completion requires writing the markdown document from template and updating state.json</critical>
<critical>SEARCH ONLY INSIDE target-repo: never scan parent directories or unrelated workspace folders</critical>

## State File

The `<output-root>` placeholder below is replaced at install time with the configured
output directory. Default: `<target-repo>/docs`.

At runtime, derive `<repo-slug>` as `basename(target-repo)`.
All artifact paths include `<repo-slug>` so that one install can serve multiple target repos.

State is stored at:
`<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/state.json`

Schema:
```json
{
  "feature": "<feature name>",
  "feature_slug": "<kebab-case>",
  "target_repo": "<absolute repo path>",
  "repo_slug": "<basename of target repo>",
  "output_root": "<absolute output root path>",
  "phase": "exploring | planning | executing | done",
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

## Status Panel

Show the status panel at the **start and end** of every run whenever state exists.

**In-progress format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Extraction: <Feature Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ <completed-doc-1>.md
  ✓ <completed-doc-2>.md
  → <next-doc>.md  (<N>/<total>)
    <remaining-doc-1>.md
    <remaining-doc-2>.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Completion format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Extraction complete: <Feature Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  <N>/<N> documents generated
  Output: <output-root>/<repo-slug>/business-rules/<feature-slug>/
  <If failed> ⚠ <M> documents need review — see state.json#failed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Entry Point — Every Run

On every invocation:

1. Resolve `target-repo` and `feature-scope` (from command text or ask).
2. Derive `feature-slug` (kebab-case from feature scope).
3. Derive `repo-slug` as `basename(target-repo)`.
4. Check if `state.json` exists at `<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/state.json`.
   - **Yes** → show status panel, route to current phase.
   - **No** → start **Phase 0 — Setup**.

Before discovery, set all file search/read commands to run within `target-repo`.
Do not perform global filesystem searches to infer output paths.

---

## Phase 0 — Setup

Collect required inputs via `AskQuestion`:

**Question 1 — Target repository** (single-select, if not already known):
Present repository options available in the current workspace context.

**Question 2 — Feature scope** (free text, if not provided in command invocation).

Persist all answers to `state.json` (phase: `"exploring"`), including `repo_slug`.

Proceed immediately to **Phase 1** in the same run.

---

## Phase 1 — Exploration

Run `explore-feature-boundaries` with target repo and feature scope.

The skill returns a taxonomy: list of sub-features, each with slug, description, entrypoints, and key files.

Persist taxonomy to state.json. Proceed to **Phase 2** in the same run.

---

## Phase 2 — Planning

Run `generate-extraction-plan` with the taxonomy.

The skill writes `PLAN.md` to `<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/PLAN.md`.

Present the plan to the user via `AskQuestion`:

**Question — Plan review** (multi-select):
"The following documents are proposed. Select any you want to **remove** from the plan."
- Show each proposed document as a selectable option.
- Default: none selected (all documents approved).

After the user responds:
- Remove selected documents from the list.
- Update `PLAN.md` after removals.

Ask the user what detail level to extract (multi-select):
- Business Rules — validation, conditions, state transitions (default selected)
- Technical Rules — API contracts, error handling, integration patterns
- Usage Context — triggers, pre/post conditions, user workflows
- Examples — concrete scenarios with payloads and state transitions

After detail selection:
- Update extraction option checkboxes in `PLAN.md`.
- Populate `state.json`:
  - `pending`: approved document slugs in PLAN.md order
  - `extraction_options`: selected options
  - `phase`: `"executing"`

Return a task preview:
- number of files to generate (`pending` count)
- selected detail level
- output directory

Show status panel. **Stop — this run is complete. Run the command again to begin extraction.**

---

## Phase 3 — Execution (one document per run)

Pick `pending[0]` from `state.json`.

Show status panel at the **start**.

Run `extract-business-rules` with:
- target repo
- sub-feature scope, entrypoints, and key files from PLAN.md row
- output path: `<output-root>/<repo-slug>/business-rules/<feature-slug>/<doc-slug>.md`
- `extraction_options` from state.json

On **success**:
- Write the returned markdown to the output path.
- Move doc from `pending[0]` to `completed` in state.json.
- If `pending` is now empty: set `phase: "done"`.

On **failure** (skill returned FAILED):
- Move doc from `pending[0]` to `failed` in state.json with reason.
- Do not write any file.

Show status panel at the **end**.

If `phase` is now `"done"`, show completion panel.
If `failed` is non-empty, list each failed document with reason and recommendation.

**Stop — run the command again for the next document.**

---

## Phase "done"

Show completion panel.

If `failed` is non-empty:
- List each failed document, its reason, and what human action is needed.
- Offer to retry a specific failed doc: ask user which (if any) to move back to `pending`.

---

## Output Paths

| Artifact | Path |
|---|---|
| Documents | `<output-root>/<repo-slug>/business-rules/<feature-slug>/<doc-slug>.md` |
| State | `<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/state.json` |
| Plan | `<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/PLAN.md` |

---

## Defaults

- `depth = full`
- `product_mode = true`
- `cross_domain_policy = reference_only`
- `extraction_options.business_rules = true` (all others false unless selected)

---

## multi_repo_compare mode

If the user requests comparison across repositories:

1. Run Phases 0–3 independently per repository, producing per-repo document sets.
2. After all repos reach `phase: "done"`, run `compare-business-rules-across-repos`.
3. Produce a consolidated document at:
   `<output-root>/<repo-slug>/business-rules/<feature-slug>-comparison.md`
   with: shared rules, repo-specific rules, behavior drift/gaps.
