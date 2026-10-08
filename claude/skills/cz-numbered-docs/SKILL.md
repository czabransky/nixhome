---
name: cz-numbered-docs
description: Reorganize a project's documentation into numbered, current-state topic docs (00–99, or 000–999 for large projects) in reading order, with an overview that indexes them, a short CLAUDE.md of always-on rules plus a "read before you touch" table, ADRs/decision logs dissolved into the topic docs, and checklists plus tech debt merged into one roadmap. Use when the user asks to restructure, reorganize, consolidate or number the docs, flatten or remove ADRs, slim down CLAUDE.md, or set up a docs table of contents; also use to add a new doc to a project already in this format. Do NOT use for writing one standalone doc, for API reference generation, or for architecture diagrams (use cz-architecture-diagram).
---

# Numbered Docs

Turn a project's scattered knowledge (a long CLAUDE.md, ad-hoc docs, ADRs, checklists, tech-debt
lists) into one flat `docs/` folder of numbered, current-state topic docs, indexed by an overview
and a short CLAUDE.md.

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

- Agent files (`CLAUDE.md`, `AGENTS.md`, nested ones), `README*`, `docs/`, ADR or decision-log
  folders, checklists, TODO and tech-debt files, scratch folders (check whether they're
  gitignored — deleting an untracked file is permanent).
- Grep everything else for references to doc paths and ADR ids: code comments, tests, scripts,
  CI, solution/project files (IDE solution folders often list docs), `.claude/skills`, and the
  project's memory directory.

## Step 2: Choose the scheme

Pick the width once and never mix:

| | 2-digit | 3-digit |
| --- | --- | --- |
| Use when | up to ~60 docs, one app | many subsystems, a monorepo, several apps |
| Orientation (overview, setup, architecture, stack, standards) | `00–09` | `000–099` |
| Cross-cutting concerns | `10–29` | `100–299` |
| Features | `30–79` | `300–799`, a hundred per app or area |
| Clients/front-ends | inside features (e.g. `40`) | inside features (e.g. `700–799`) |
| Operations (config, deployment, CI, runbooks) | `90–98` | `900–989` |
| Roadmap | `99` | `999` |

- `00`/`000` is always the overview. `01`/`001` is usually workstation setup.
- Filenames: `NN-kebab-topic.md`, flat in `docs/`. Leave gaps within each band.
- A topic is a concern a developer reasons about as a unit (tenancy, error handling, sessions),
  not a code folder. Merge thin topics; split one that mixes unrelated rules.

## Step 3: Map sources to docs, and confirm

Draft a table: target doc ← sources (which sections of which files, which ADRs). Every ADR and
every section of the current agent file must land somewhere or be deliberately dropped. Show the
user the scheme, the doc list and the map, and ask about anything that's genuinely their call
(where reasoning goes, what to do with checklists) before writing. In plan mode, this is the plan.

## Step 4: Write

Work on a branch. Don't stage the user's unrelated uncommitted changes.

1. `git mv` existing docs to their numbered names and commit that alone, so history follows them.
2. Write each topic doc as a first version, using the shape in `references/templates.md`:
   what it does → how it works → rules when changing it → key files. Link related docs by
   relative path (`[14-tenancy](14-tenancy.md)`).
3. **Verify claims against the code as you write.** Old docs drift: file paths move, behaviors
   change, features get removed. Check paths with `fd`, behavior with `rg`. Fix what's wrong and
   keep a list to report.
4. **Dissolve ADRs.** Tick each decision off against its doc. Keep current decisions and
   guard-rail reasoning; drop dates, statuses, consequences lists, superseded decisions and
   rejected alternatives nobody would reach for. Something an ADR removed but that might come
   back (a feature taken out for being unsafe) becomes a roadmap item stating the condition for
   bringing it back. Then delete the ADR folder and any solution/IDE references to it.
5. **Roadmap** (`99`/`999`): a "before it's ready" section from open checklist items, then known
   gaps and deferred work grouped by area, each with why it's deferred. Drop "done" lists — the
   overview describes what exists. Remove duplicates between checklist and debt.
6. **Overview** (`00`/`000`): what the project is, how the numbering works, one table per band
   linking every doc with a one-line description, and the doc-maintenance rules.
7. **Agent file** (CLAUDE.md, or whatever the project uses): identity paragraph, build/test
   commands, always-on rules each tagged with its doc number, a "When you're… → Read" table, and
   the doc-maintenance rules. Aim for under ~80 lines. Don't drop a rule from it unless that rule
   now lives in a doc.
8. Repoint every reference found in Step 1 (code comments cite `docs/NN-topic.md`, not ADR ids).
   Update memory files that point at old paths.

## Step 5: Verify

- Grep for old file names and ADR ids: nothing left outside git history.
- Check links: every relative `.md` link in `docs/`, the README and the agent file resolves,
  every doc number named in the agent file exists, and every doc appears in the overview. A
  short script does this; see `references/templates.md`.
- Build, and run tests that read the touched files (architecture tests often cite docs in
  comments; a solution file edit needs a build). Run any rebrand/codegen script that rewrites
  docs in dry-run mode.
- Commit per step: renames; topic docs + ADR removal; roadmap; agent file; references.

## Step 6: Report

Lead with the branch and commits, then: the doc list by band, what was dropped from ADRs and why,
drift corrected (old doc said X, code does Y), anything kept that looks out of scope, and the
next command (push/PR). Don't push or open a PR unless asked.

## Adding a doc later

In a project already in this format: take the next free number in the right band (never
renumber existing docs unless asked), use the topic template, add a row to the overview, and add
a row to the agent file's "Read" table if the doc has a clear trigger. If a band is full, tell
the user rather than spilling into another band.
