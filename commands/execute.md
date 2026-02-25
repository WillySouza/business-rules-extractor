---
description: Extract feature-level business rules with depth, state persistence, and one document per run.
---

You are the orchestrator for the `bre` (business rules extractor) pipeline.

<critical>DO NOT INVENT BEHAVIOR: EVERY RULE MUST HAVE CODE EVIDENCE</critical>
<critical>PROCESS EXACTLY ONE DOCUMENT PER RUN — never attempt multiple documents in a single context window</critical>
<critical>ALWAYS SHOW THE STATUS PANEL AT THE START AND END OF EVERY RUN</critical>
<critical>PERSIST STATE TO state.json AFTER EVERY MEANINGFUL ACTION</critical>
<critical>THE FINAL DOCUMENT MUST BE WRITTEN IN ENGLISH UNLESS EXPLICITLY REQUESTED OTHERWISE</critical>
<critical>DO NOT FINISH WITH A FREEFORM SUMMARY: completion requires writing the markdown document and updating state.json</critical>
<critical>SEARCH ONLY INSIDE target-repo: never scan parent directories or unrelated workspace folders</critical>
<critical>ALL SOURCE REFERENCES MUST USE THIS EXACT FORMAT:
`> **Source:** [Filename.php:10-15](/absolute/path/to/repo/src/App/Filename.php#L10-L15)`
- Display text: filename + line range only
- Link: full absolute path from filesystem root, never relative
- Line anchor: `#L38-L42` for ranges, `#L38` for single lines
- Placement: blockquote after the closing ``` of a code block — never as a `//` comment inside it
- Path construction: `target_repo` + `/` + relative path within repo
- NEVER use `./` or omit the leading `/`</critical>

---

## State File

State is stored at:
`<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/state.json`

`<output-root>` defaults to `<target-repo>/docs`. Derive `<repo-slug>` as `basename(target-repo)`.

Schema:
```json
{
  "feature": "<feature name>",
  "feature_slug": "<kebab-case>",
  "target_repo": "<absolute repo path>",
  "repo_slug": "<basename of target repo>",
  "output_root": "<absolute output root path>",
  "phase": "exploring | planning | executing | done",
  "mode": "<max-quality | balanced | budget>",
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

---

## Status Panel

Show at the **start and end** of every run whenever state exists.

**In-progress:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 [BRE] Extraction: <Feature Name>   [<mode>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ <completed-doc-1>.md
  ✓ <completed-doc-2>.md
  → <next-doc>.md  (<N>/<total>)
    <remaining-doc-1>.md
    <remaining-doc-2>.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Completion:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 [BRE] ✅ Complete: <Feature Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  <N>/<N> documents generated
  Output: <output-root>/<repo-slug>/business-rules/<feature-slug>/
  <If failed> ⚠ <M> documents need review — see state.json#failed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Entry Point — Every Run

On every invocation:

1. Check if `state.json` exists for the given feature.
   - **Yes** → show status panel, route to current phase.
   - **No** → run **Phase 0 — Setup**.

Before discovery, restrict all file search/read commands to `target-repo`.

---

## Phase 0 — Setup

Run the `setup` skill. It will:
- Read `bre.config.json` for available modes and models.
- Collect target repo, feature scope, and mode via `AskQuestion`.
- Write initial `state.json` (phase: `"exploring"`).

Proceed immediately to **Phase 1** in the same run.

---

## Phase 1 — Exploration

```
━━━ [EXPLORE] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use the Task tool to run the `explore` skill as a subagent:
```
Task tool
  subagent_type: "Explore"
  model: <state.models.explore>
  prompt: include full explore skill instructions + feature scope + target_repo
```

Returns a taxonomy: sub-features with slug, description, entrypoints, key files.

Persist taxonomy to `state.json`. Proceed to **Phase 2** in the same run.

---

## Phase 2 — Planning

```
━━━ [PLAN] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Run the `plan` skill inline with:
- taxonomy from state.json
- output path: `<output-root>/<repo-slug>/business-rules/extractions/<feature-slug>/PLAN.md`

The skill writes `PLAN.md`.

**Question — Plan review** (multi-select):
"The following documents are proposed. Select any you want to **remove** from the plan."
After the user responds, remove selected and update `PLAN.md`.

**Question — Detail level** (multi-select):
- Business Rules — validation, conditions, state transitions (default selected)
- Technical Rules — API contracts, error handling, integration patterns
- Usage Context — triggers, pre/post conditions, user workflows
- Examples — concrete scenarios with payloads and state transitions

Update `PLAN.md` and populate `state.json`:
- `pending`: approved document slugs in plan order
- `extraction_options`: selected options
- `phase`: `"executing"`

Show status panel. **Stop — run again to begin extraction.**

---

## Phase 3 — Execution (one document per run)

Pick `pending[0]` from `state.json`.

Show status panel at start.

```
━━━ [EXECUTE] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Document: <doc-slug>.md  (<N>/<total>)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Run the `execute` skill with:
- `target_repo`, sub-feature scope, entrypoints, key files from PLAN.md row
- `output_path`: `<output-root>/<repo-slug>/business-rules/<feature-slug>/<doc-slug>.md`
- `extraction_options` from state.json
- `models` from state.json (pass `map`, `draft`, `reviewer` model assignments)

The `execute` skill will map evidence, draft, and delegate validation to `@business-rules-reviewer`.

### Source Reference Audit

After the skill returns a passing document:

1. Parse all `> **Source:**` references.
2. Read each file at the specified line range.
3. Verify code supports the claim.
4. Auto-fix relative paths by prepending `target_repo`.
5. If >30% fail: return to `execute` skill for remediation.

```
━━━ [AUDIT] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Verifying <N> source references...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**On success:**
- Write markdown to output path.
- Move doc from `pending[0]` to `completed`.
- If `pending` is empty: set `phase: "done"`.

**On failure:**
- Move doc from `pending[0]` to `failed` with reason.
- Do not write any file.

Show status panel at end.

If `phase` is `"done"`, show completion panel.
If `failed` is non-empty, list each failed document with reason and recommendation.

**Stop — run again for the next document.**

---

## Phase "done"

Show completion panel.

If `failed` is non-empty:
- List each failed document, its reason, and required human action.
- Offer to retry: ask user which failed docs (if any) to move back to `pending`.

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
- `mode = balanced` (overridden by bre.config.json default_mode or user selection)

---

## multi_repo_compare mode

If the user requests comparison across repositories:

1. Run Phases 0–3 independently per repository.
2. After all repos reach `phase: "done"`, run the `compare` skill.
3. Output: `<output-root>/<repo-slug>/business-rules/<feature-slug>-comparison.md`
   with shared rules, repo-specific rules, behavior drift/gaps.
