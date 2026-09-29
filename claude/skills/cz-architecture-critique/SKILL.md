---
name: cz-architecture-critique
description: Run a devil's-advocate, risk-finding pass on an existing architecture — a design doc, an architecture diagram (current or target state), or a described decision — surfacing failure modes, scaling limits, unstated assumptions, and simpler alternatives that weren't considered. Use when the user asks to "poke holes in", "critique", "stress-test", "play devil's advocate on", or "find risks/weaknesses in" a design, diagram, or decision. Distinct from code-review (reviews code diffs, not design artifacts) and from cz-architecture-design (proposes new options rather than attacking an existing one).
---

# Architecture Critique (Devil's Advocate)

Attack an existing architectural decision or diagram to find what would
break it. Never propose new architecture options (that's
`cz-architecture-design`) and never edit code.

## Step 1: Read the artifact under review

Identify and fully read what's being critiqued: an architecture diagram
file, a design doc, pasted text, or a PR description.

## Step 2: Verify claims against the codebase

Where checkable, confirm the artifact's factual claims against the actual
code rather than taking the document's word for it — e.g. if a current-state
diagram claims a component already handles retries, verify that in the code.

## Step 3: Work an adversarial checklist

Go through each of these explicitly rather than giving free-form opinion:

- Correctness of stated requirements.
- Failure modes — what happens when a dependency is down.
- Scaling limits — what breaks at 10x load/data/users.
- Operational burden — on-call, observability, rollback.
- Security/compliance gaps.
- Cost.
- Team/ownership fit.
- Simpler alternatives not considered.
- Reversibility.
- Hidden coupling.

## Step 4: Report findings by severity

Order findings strongest-first. Tag each as blocker/serious/minor. Every
finding needs a concrete mitigation or open question attached — never just
"this is bad."

## Step 5: Give a verdict

State explicitly whether the design is decision-ready or not, and name the
specific objections that would flip the decision if left unresolved.

## Step 6: Offer, don't perform, follow-up

Offer to fold specific risks into the architecture diagram or design doc via
`cz-architecture-diagram` — don't make that edit yourself as part of this
skill.
