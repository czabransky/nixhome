---
name: cz-numbered-docs
description: Reorganize a project's documentation into numbered, current-state topic docs in reading order, either one flat `docs/` folder (00–99, or 000–999 for large projects) or one numbered sequence per scope (platform, backend, frontend…) under a docs root with an unnumbered index, plus a short CLAUDE.md of always-on rules and a "read before you touch" table (nested per app when scoped), with ADRs/decision logs dissolved into the topic docs and deferred work merged into one roadmap doc unless the project keeps its roadmap elsewhere. Use when the user asks to restructure, reorganize, consolidate or number the docs, flatten or remove ADRs, slim down CLAUDE.md, set up a docs table of contents, or dissolve one scope's docs in a monorepo; also use to add a new doc to a project already in this format. Do NOT use for writing one standalone doc, for API reference generation, or for architecture diagrams (use cz-architecture-diagram).
---

# Numbered Docs

Turn a project's scattered knowledge (a long CLAUDE.md, ad-hoc docs, ADRs, checklists, tech-debt
lists) into numbered, current-state topic docs, indexed by an overview and a short CLAUDE.md.

## Principles

- **One topic, one doc, current state only.** Each rule lives in exactly one place, so it can't
  drift between copies. No history, dates, statuses or "previously".
- **Load on demand.** CLAUDE.md is always in context, so it holds only the rules whose violation
  is silent or security-relevant, plus a table telling an agent which doc to read before touching
  an area. Everything else is read when needed.
- **No superseded reasoning in context.** An agent that reads a replaced decision may act on it.
  Keep a "why" only when it's current and guards against a tempting wrong change, phrased as a
  rule with its reason ("X isn't in the cache: it needs an atomic claim every instance sees").
- **Numbers are reading order.** Low numbers orient a newcomer; higher bands go deeper. Gaps
  between numbers keep them stable when docs are added.

## Step 1: Inventory

Read every source fully before planning:

- Agent files (`CLAUDE.md`, `AGENTS.md`, nested ones), `README*`, `docs/`, per-app doc folders,
  ADR or decision-log folders, checklists, TODO and tech-debt files, scratch folders (check
  whether they're gitignored — deleting an untracked file is permanent).
- Grep everything else for references to doc paths and ADR ids: code comments, tests, scripts,
  CI, Dockerfiles, solution/project files (IDE solution folders often list docs),
  `.claude/skills`, `.agents/skills`, and the project's memory directory.
- Find out where the project already keeps things the docs would otherwise hold: a roadmap or
  planning tool, product or feature pages, a glossary. Docs link to these instead of copying them.

## Step 2: Choose the layout

### Flat or scoped

| | Flat | Scoped |
| --- | --- | --- |
| Use when | one app, or a repo whose developers read all of it | a monorepo whose apps are worked on separately, or docs rendered on a site by folder |
| Where | `docs/NN-topic.md` | `<root>/<scope>/NN-topic.md`, plus `<root>/index.md` |
| Numbering | one sequence, 2 or 3 digits | one 2-digit sequence per scope; nothing is numbered across scopes |
| Agent files | one `CLAUDE.md` | root `CLAUDE.md`, plus a nested `CLAUDE.md` in each app folder |
| Doc references | `NN` | `scope/NN` |

- A **scope** is an area a developer works in as a unit: usually one per app (`backend`,
  `frontend`, `mcp`), plus `platform` for what spans apps (setup, environments, deployment,
  secrets, disaster recovery, the architecture overview). Follow the project's existing split if
  it has one.
- `<root>` is wherever the project publishes docs: `docs/`, or a docs site's content folder.
  Ask if it isn't clear.
- `<root>/index.md` is unnumbered: one line per scope saying what it covers and who reads it,
  linking each scope's overview. It's a map, not a reading order.
- Use 3-digit flat numbering for a single large app with many subsystems. For several apps,
  prefer scopes over 3-digit bands per app: a folder per app is visible in the file tree and on
  a site, and an agent working in one app needs no other app's numbers.

### Bands

Pick the width once and never mix within a sequence:

| | 2-digit | 3-digit (flat only) |
| --- | --- | --- |
| Orientation (overview, setup, architecture, stack, standards) | `00–09` | `000–099` |
| Cross-cutting concerns | `10–29` | `100–299` |
| Features | `30–79` | `300–799`, a hundred per area |
| Clients/front-ends | inside features (e.g. `40`) | inside features (e.g. `700–799`) |
| Operations (config, deployment, CI, runbooks) | `90–98` | `900–989` |
| Roadmap | `99` | `999` |

- `00`/`000` is always the overview, in every scope. `01`/`001` is usually workstation setup;
  in a scoped layout, setup lives once in `platform/01`, and an app's `01` covers only what's
  specific to running that app.
- Filenames: `NN-kebab-topic.md`. Leave gaps within each band.
- A topic is a concern a developer reasons about as a unit (tenancy, error handling, sessions),
  not a code folder. Merge thin topics; split one that mixes unrelated rules.
- **Feature docs describe implementation.** When the project has product or feature pages that
  say what users can do and the business rules, a doc in the features band covers how the code
  does it and links to the feature page rather than restating its rules.

### Roadmap

The roadmap doc (`99`/`999`) holds what's left and what's deliberately deferred. When the project
already keeps a roadmap elsewhere (a planning tool, a roadmap file a site renders, a tracker),
don't create one: name that home in Step 3, and send open checklist items, known gaps, deferred
work and removed-but-might-return features there instead. Each doc's "Keeping docs current"
rules then point at that home.

## Step 3: Map sources to docs, and confirm

Draft a table: target doc ← sources (which sections of which files, which ADRs). Every ADR and
every section of the current agent file must land somewhere or be deliberately dropped. Show the
user the layout, the doc list and the map, and ask about anything that's genuinely their call
(scope boundaries, where reasoning goes, where deferred work goes, what to do with checklists)
before writing. In plan mode, this is the plan.

In a scoped layout, map and write one scope at a time, `platform` first, since the app scopes
link to it. A scope that already exists keeps its numbers; new docs take the next free number in
their band.

## Step 4: Write

Work on a branch. Don't stage the user's unrelated uncommitted changes.

1. `git mv` existing docs to their numbered names and commit that alone, so history follows them.
2. Write each topic doc as a first version, using the shape in `references/templates.md`:
   what it does → how it works → rules when changing it → key files. Link related docs by
   relative path: `[14-tenancy](14-tenancy.md)` within a scope,
   `[platform/20-secrets](../platform/20-secrets.md)` across scopes.
3. **Verify claims against the code as you write.** Old docs drift: file paths move, behaviors
   change, features get removed. Check paths with `fd`, behavior with `rg`. Fix what's wrong and
   keep a list to report.
4. **Dissolve ADRs.** Tick each decision off against its doc. Keep current decisions and
   guard-rail reasoning; drop dates, statuses, consequences lists, superseded decisions and
   rejected alternatives nobody would reach for. Something an ADR removed but that might come
   back (a feature taken out for being unsafe) becomes a roadmap item stating the condition for
   bringing it back, in whichever roadmap Step 2 chose. Then delete the ADR folder and any
   solution/IDE references to it.
5. **Roadmap**, unless the project keeps it elsewhere (`99`/`999`): a "before it's ready" section
   from open checklist items, then known gaps and deferred work grouped by area, each with why
   it's deferred. Drop "done" lists — the overview describes what exists. Remove duplicates
   between checklist and debt.
6. **Overview** (`00`/`000`, one per scope): what the project or scope is, how the numbering
   works, one table per band linking every doc with a one-line description, and the
   doc-maintenance rules. In a scoped layout, also write or update `<root>/index.md`.
7. **Agent files** (CLAUDE.md, or whatever the project uses):
   - Flat: identity paragraph, build/test commands, always-on rules each tagged with its doc
     number, a "When you're… → Read" table, and the doc-maintenance rules. Aim for under ~80
     lines.
   - Scoped: the root file keeps the identity paragraph, commands, the always-on rules that span
     apps (tagged `scope/NN`), a "When you're… → Read" table whose rows name scopes or docs, and
     the doc-maintenance rules. Each app folder gets a short nested `CLAUDE.md` (under ~30 lines):
     which scope to read before changing code there, that scope's always-on rules, and the
     commands specific to the app. Claude Code loads a nested `CLAUDE.md` when it works in that
     subtree.
   - Don't drop a rule from an agent file unless that rule now lives in a doc.
8. Repoint every reference found in Step 1 (code comments cite `docs/NN-topic.md`, or
   `<root>/<scope>/NN-topic.md`, not ADR ids). Update memory files that point at old paths.

## Step 5: Verify

- Grep for old file names and ADR ids: nothing left outside git history.
- Check links: every relative `.md` link in the docs, the README and the agent files resolves,
  every doc number named in an agent file exists, and every doc appears in its overview. Short
  scripts for both layouts are in `references/templates.md`.
- Build, and run tests that read the touched files (architecture tests often cite docs in
  comments; a solution file edit needs a build). Run any rebrand/codegen script that rewrites
  docs in dry-run mode. When the docs render on a site, build the site.
- Commit per step: renames; topic docs + ADR removal; roadmap; agent files; references. In a
  scoped layout, one branch or PR per scope.

## Step 6: Report

Lead with the branch and commits, then: the doc list by scope and band, what was dropped from
ADRs and why, where deferred work went, drift corrected (old doc said X, code does Y), anything
kept that looks out of scope, and the next command (push/PR). Don't push or open a PR unless
asked.

## Adding a doc later

In a project already in this format: take the next free number in the right band of the right
scope (never renumber existing docs unless asked), use the topic template, add a row to that
scope's overview, and add a row to the matching agent file's "Read" table if the doc has a clear
trigger. A new scope gets its own `00-overview.md`, a line in `<root>/index.md`, and a nested
agent file if it's an app. If a band is full, tell the user rather than spilling into another
band.
