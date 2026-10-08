# Templates

Skeletons for the numbered-docs format. Replace `NN` with the project's width (`00` or `000`).

## Overview (`docs/00-overview.md`)

```markdown
# <Project> Overview

<One paragraph: what the project is, who uses it, how it's reused or deployed.>

The docs are numbered in reading order: 00–09 orient you, 10–29 cover cross-cutting concerns,
30–79 cover features, and 90–99 cover operations and what's left to do. Each describes the
system as it is today.

## Start here

| Doc | What it covers |
| --- | --- |
| [01 Workstation setup](01-workstation-setup.md) | Running it locally; everyday commands |
| [02 Architecture](02-architecture.md) | Layers, boundaries, where new code goes |

## Cross-cutting concerns

| Doc | What it covers |
| --- | --- |

## Features

| Doc | What it covers |
| --- | --- |

## Operations and roadmap

| Doc | What it covers |
| --- | --- |
| [99 Roadmap](99-roadmap.md) | What's left; known gaps and deferred work |

## Keeping the docs current

- Update the topic doc in the same change as the code it describes, written as the current state.
- A new local dependency, secret or setup step → 01.
- A new required setting → the configuration doc (and CI, if CI checks settings).
- Anything deliberately deferred → 99.
- A new topic gets the next free number in its band and a row here.
```

## Topic doc

```markdown
# <Topic>

<Open with the problem the topic solves or the constraint that shapes it, in one or two
sentences — not a definition.>

## How it works

<Mechanism, components and their order. Tables for enumerations (status codes, jobs, settings).>

## Rules

<What someone changing this area must do or never do, each with its reason when the reason
isn't obvious. Current guard-rail reasoning from ADRs lands here.>

## Limits

<Optional: known limits that matter when using it; deferred fixes go to the roadmap instead.>

## Key files

- `path/to/File` — what it is.
```

Headings are nouns, never questions. Link related docs by relative path.

## Roadmap (`docs/99-roadmap.md`)

```markdown
# Roadmap

What's left before <milestone>, then the known gaps and deliberately deferred work, each with a
note on why. Add to it whenever a change defers something; remove an item when it's done.

## Before <milestone>

- [ ] **<Item>.** <What and why it matters.>

## Known gaps and deferred work

### <Area>

- **<Gap>.** <What's missing, why it's deferred, what would fix it.>
```

## Agent file (CLAUDE.md)

```markdown
# <Project>

<One paragraph: what it is and how it's reused.>

`docs/00-overview.md` indexes every doc. Read the docs for the area you're changing before you
change it; they describe the current state and are the source of truth.

## Build / run / test

    <commands>

## Always-on rules

Breaking one of these fails silently or leaks data; each doc linked has the detail.

- <Rule>. (NN)

## Read before you touch

| When you're… | Read |
| --- | --- |
| <Adding an endpoint> | `NN-topic`, `NN-topic` |

All paths are under `docs/`.

## Keeping docs current

- Update the topic doc in the same change, written as the current state — no history.
- Anything deliberately deferred → `docs/99-roadmap.md`.
- A new topic gets the next free number in its band and a row in `docs/00-overview.md`.
```

## Link check

Run from the repository root; adjust the agent file name and the number width.

```python
import glob, os, re
files = glob.glob('docs/*.md') + ['README.md', 'CLAUDE.md']
bad = 0
for f in files:
    if not os.path.exists(f):
        continue
    for m in re.finditer(r'\]\(([^)#\s]+)(#[^)]*)?\)', open(f).read()):
        target = m.group(1)
        if target.startswith('http'):
            continue
        if not os.path.exists(os.path.join(os.path.dirname(f), target)):
            print('broken', f, target); bad += 1
for name in re.findall(r'`(\d{2,3}-[a-z0-9-]+)`', open('CLAUDE.md').read()):
    if not os.path.exists(f'docs/{name}.md'):
        print('CLAUDE.md names missing doc', name); bad += 1
overview = open(sorted(glob.glob('docs/0*-overview.md'))[0]).read()
for f in sorted(glob.glob('docs/*.md')):
    b = os.path.basename(f)
    if not b.endswith('-overview.md') and b not in overview:
        print('not in overview', b); bad += 1
print('problems:', bad)
```
