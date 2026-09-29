---
name: cz-architecture-diagram
description: Create or update a curated diagram of a project's architecture — its current state, target/future state, or both — filed under docs/architecture/ (or the project's existing convention, if one exists). Use when the user asks to diagram the architecture, update the architecture diagram, show the target/future shape, or naturally after a cz-architecture-design conversation concludes with a chosen approach. Treats the diagram as a hand-curated artifact: match whatever format already exists (Mermaid, ASCII, PlantUML, prose, external links) rather than regenerating it, and never invent a current-state diagram the project doesn't want — many projects only model the target shape. Do NOT use this to draft architecture options (use cz-architecture-design). Do NOT use for anything that isn't a structural/architecture diagram.
---

# Architecture Diagram

Maintain a curated diagram of a project's current and/or target
architecture. The diagram is authored and owned by the user — this skill
makes targeted, respectful edits, not wholesale regenerations.

## Step 1: Find the existing diagram, if any

Look for `docs/architecture/` (or the project's own equivalent — check
README or existing docs conventions first). If a current-state or
future-state file already exists, read it fully and note its exact format
(Mermaid, ASCII art, PlantUML, prose description, a link to an external
tool) and level of detail. Match that format — do not convert it to a
different notation and do not reformat unrelated parts of the file.

## Step 2: Determine what's being targeted

Ask only if ambiguous: is this modeling the *current* state, the
*target/future* state, or both? Do not assume both are wanted — many
projects intentionally model only the target shape, especially greenfield
ones. Never create a current-state file the user didn't ask for.

## Step 3: If no file exists yet

Confirm the filename before creating it — default to:

- `docs/architecture/current.md`
- `docs/architecture/future.md`

Default to Mermaid embedded in markdown as the starting format. Make clear
this is a starting point for the user to curate further, not a finished,
AI-authored artifact — keep the first version minimal and let them steer
its evolution.

When writing Mermaid, never put a literal semicolon in node/edge text or
labels — Mermaid reserves `;` as a statement separator, so it breaks
rendering even inside what looks like plain label text. Rephrase instead of
escaping.

## Step 4: Editing an existing file

Make a targeted edit reflecting the specific change (e.g. a new component
from a just-decided architecture). Preserve everything else in the file —
untouched sections, existing notation style, existing level of abstraction.
Show the user what changed before/after, since this file is curated content
they're relying on, not disposable output.

## Step 5: Cross-link with design decisions

When following a `cz-architecture-design` conversation, offer to reflect the
chosen shape into the future-state diagram. Do not touch a current-state
diagram just because a decision was made — only update it once the system
itself has actually changed (i.e. after implementation, not after a
decision).

## Step 6: Write and report

Write the file. Report the path and a summary of what changed. Never commit
or run git commands unless explicitly asked.

## Step 7: Hand off

Close by offering to move to implementation planning (plan mode / the Plan
agent) rather than continuing further diagram work unprompted.
