---
name: cz-architecture-design
description: Facilitate structured architecture exploration for a new system, service, or significant feature before any code or implementation plan exists. Explore the existing codebase for relevant patterns and constraints, ask about requirements and non-functional requirements, then propose 2-3 candidate architectures with explicit tradeoffs and help pick one. Use when the user wants to think through system/feature design, weigh architectural approaches, asks "how should I architect/design X" or "should we do X or Y", or is deciding on a technical approach before building anything. Do NOT use for planning the implementation steps of an approach that's already decided (use plan mode instead). Do NOT use for reviewing code diffs (use code-review). Do NOT use for drawing or updating the architecture diagram once a decision is made (use cz-architecture-diagram).
---

# Architecture Design

Guide the user through picking an architecture before any implementation
plan is written. This skill never writes files and never plans
implementation steps — it ends by handing off to `cz-architecture-diagram`
or to plan mode.

## Step 1: Scope the decision

State in one line what's being decided: a new system, a new feature within
an existing system, or evolving an existing component. Confirm the target
project is the current working directory unless told otherwise.

## Step 2: Explore before asking

Read the codebase before asking the user anything answerable by reading it:

- Look for `docs/architecture/` and any existing current/future diagram.
- Look for README sections describing architecture.
- Identify frameworks, libraries, and architectural patterns already in use.
- Find the most similar existing feature/component as precedent.

Never ask the user something the repo already answers.

## Step 3: Ask requirements and constraints

Use `AskUserQuestion`, batched into as few rounds as possible, covering:

- Functional scope and explicit non-goals.
- Non-functional requirements: scale, latency, consistency, security/
  compliance.
- Hard constraints: must-use technology, deadline, team size/ownership.
- What's explicitly out of scope for this decision.

## Step 4: Draft 2-3 candidate architectures

For each candidate:

- One-paragraph summary.
- Key components (short list or a small diagram sketch).
- How it satisfies the stated requirements.
- A reversibility note — how hard this would be to undo later.

## Step 5: Tradeoff table

Present one tradeoff table comparing all candidates side by side (not
separate prose per candidate) so they're comparable at a glance.

## Step 6: Decide

Use `AskUserQuestion` for the actual pick, or an explicit blend of two
options. Iterate once if the user pushes back on the options presented.

## Step 7: Hand off

Close with a short decision summary and an explicit fork — do neither of
these yourself:

- "Want me to update the architecture diagram to reflect this?" → the user
  can invoke `cz-architecture-diagram`.
- "Ready to plan the implementation?" → plan mode / the Plan agent.
