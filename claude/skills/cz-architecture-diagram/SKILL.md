---
name: cz-architecture-diagram
description: Create or update a curated diagram of a project's architecture — its current state, target/future state, or both — filed under docs/architecture/ (or the project's existing convention, if one exists). Use when the user asks to diagram the architecture, update the architecture diagram, show the target/future shape, or naturally after a cz-architecture-design conversation concludes with a chosen approach. Treats the diagram as a hand-curated artifact: match whatever format already exists (a YAML model rendered by a command, Mermaid, ASCII, PlantUML, prose, external links) rather than regenerating it, and never invent a current-state diagram the project doesn't want — many projects only model the target shape. Do NOT use this to draft architecture options (use cz-architecture-design). Do NOT use for anything that isn't a structural/architecture diagram.
---

# Architecture Diagram

Maintain the diagrams of a project's current and/or target architecture.
The diagrams are authored and owned by the user. This skill makes targeted
edits, never wholesale regenerations.

## Step 1: Find how the project draws architecture

Check, in this order:

1. **A model rendered by a command.** Look for `architecture/<system>/model.yaml`
   (or similar YAML/JSON models), a `changes/` folder next to it, and a
   script that renders them (`pnpm arch render`, a Makefile target, a docs
   page describing the commands). Read the project's diagram docs fully
   before editing anything. In this setup you edit the model and render;
   you never edit the generated SVGs or briefs.
2. **Curated files.** `docs/architecture/` or the project's equivalent
   (check README and existing docs conventions). Note the exact format
   (Mermaid, ASCII art, PlantUML, prose, a link to an external tool) and
   level of detail, and match it. Don't convert notation or reformat
   unrelated parts.
3. **Nothing.** Go to Step 4.

## Step 2: Determine what's being targeted

Ask only if ambiguous: is this the *current* state, the *target/future*
state, or both? Don't assume both. Many projects model only the target
shape. Never create a current-state file the user didn't ask for. In a
model-driven project, a planned change is a change file against the model,
and the model itself changes only when the change is delivered.

## Step 3: Choose the views

Each view answers one question. If a diagram needs to answer a second
question, it's two views or a table.

| View | Question | Include when |
|---|---|---|
| Container | What runs, what stores data, and who talks to the system? | Always for a change |
| Component | What changes inside this container, and which module dependencies does it add? | A container's modules change |
| Flow (sequence) | What happens, in order, in one scenario? | One per user-visible or background scenario |
| Lifecycle (state) | What states can this thing be in, and what moves it? | A long-lived thing with more than two states |
| Stored data (table) | What's stored, where, whose is it, how long, who reads and writes it? | The change stores new data |

Leave out a view that would repeat another. Don't put decisions, data
stores' users or step order on a structural view; they belong in the brief,
the data table and the flows.

Keep each view readable at the width of a docs page:

- about 8 participants per flow and up to 15 steps; split a longer scenario
  into several flows;
- labels under 60 characters, written as a verb phrase from the caller's
  side;
- at most 5 states on a lifecycle's main path and 9 in total;
- names and responsibilities in domain terms, never code identifiers, file
  names or class names.

If the project's renderer enforces its own budgets, follow those instead.

## Step 4: Write or edit

**Model-driven project:** edit the model or change file. Let flows imply
relationships when the project derives them; add one only when no flow
implies it. Then run the project's validate and render commands, fix every
error and warning you introduced, and report any warnings that were already
there. Look at the rendered output if you can rasterize it; otherwise say
you didn't.

**Curated files:** make a targeted edit reflecting the specific change.
Preserve untouched sections, notation and level of abstraction. Show the
user the before and after.

**No convention yet:** confirm the filename before creating anything,
defaulting to `docs/architecture/current.md` or `docs/architecture/future.md`.
Use Mermaid in Markdown, one fenced diagram per view from Step 3, each under
a heading that states its question. Keep the first version minimal: it's a
starting point for the user to curate.

When writing Mermaid, never put a literal semicolon in node or edge text.
Mermaid reads `;` as a statement separator even inside label text, which
breaks rendering. Rephrase instead of escaping.

## Step 5: Cross-link with design decisions

After a `cz-architecture-design` conversation, offer to reflect the chosen
shape into the target-state views, recording the decision in the project's
own format (for example a `decisions:` entry with what's fixed and what's
left to the implementer). Don't touch a current-state diagram because a
decision was made. Update it once the system itself has changed.

## Step 6: Report

Report the files changed, the views added or removed, and the validation
result. Never commit or run git commands unless explicitly asked.

## Step 7: Hand off

Offer to move to implementation planning (plan mode or the Plan agent)
rather than continuing diagram work unprompted.
