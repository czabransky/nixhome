# Templates

Skeletons for the numbered-docs format. Replace `NN` with the project's width (`00` or `000`).
In a scoped layout, every scope uses the overview and topic templates with 2-digit numbers, and
`docs/` below means `<root>/<scope>/`.

## Contents

- [Index (scoped only, `<root>/index.md`)](#index-scoped-only-rootindexmd)
- [Overview (`docs/00-overview.md`)](#overview-docs00-overviewmd)
- [Topic doc](#topic-doc)
- [Roadmap (`docs/99-roadmap.md`)](#roadmap-docs99-roadmapmd)
- [Agent file (CLAUDE.md)](#agent-file-claudemd)
- [Nested agent file (scoped only, `apps/<app>/CLAUDE.md`)](#nested-agent-file-scoped-only-appsappclaudemd)
- [Link check (flat)](#link-check-flat)
- [Link check (scoped)](#link-check-scoped)

## Index (scoped only, `<root>/index.md`)

```markdown
# <Docs title>

How <project> is built and run, as it is now. Each scope is a numbered sequence of docs in
reading order, starting with its overview.

- [Platform](platform/00-overview.md): setup, environments, deployment and what spans the apps.
- [Backend](backend/00-overview.md): <one line on what it covers and who reads it>.

<Links to what the docs don't hold: the roadmap, product or feature pages, the glossary.>
```

## Overview (`docs/00-overview.md`)

```markdown
# <Project> Overview

<One paragraph: what the project is, who uses it, how it's reused or deployed.>

The docs are numbered in reading order: 00–09 orient you, 10–29 cover cross-cutting concerns,
30–79 cover features, and 90–99 cover operations and what's left to do. Each describes the
system as it is today.

## Contents

- [Start here](#start-here)
- [Cross-cutting concerns](#cross-cutting-concerns)
- [Features](#features)
- [Operations and roadmap](#operations-and-roadmap)
- [Keeping the docs current](#keeping-the-docs-current)

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
- A heading added, renamed or removed → that doc's contents list.
```

## Topic doc

```markdown
# <Topic>

<Open with the problem the topic solves or the constraint that shapes it, in one or two
sentences — not a definition.>

## Contents

- [How it works](#how-it-works)
- [Rules](#rules)
- [Limits](#limits)
- [Key files](#key-files)

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

Headings are nouns, never questions. The contents list matches the headings below it: `##`
headings at the top level, `###` headings nested under their section. Link related docs by
relative path.

## Roadmap (`docs/99-roadmap.md`)

Skip this doc when the project keeps its roadmap elsewhere; the overview's "Keeping the docs
current" rules then send deferred work to that home instead of `99`.

```markdown
# Roadmap

What's left before <milestone>, then the known gaps and deliberately deferred work, each with a
note on why. Add to it whenever a change defers something; remove an item when it's done.

## Contents

- [Before <milestone>](#before-milestone)
- [Known gaps and deferred work](#known-gaps-and-deferred-work)
  - [<Area>](#area)

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
- A heading added, renamed or removed → that doc's contents list.
```

## Nested agent file (scoped only, `apps/<app>/CLAUDE.md`)

```markdown
# <App>

Before changing code here, read `<root>/<scope>/00-overview.md` and the docs it points you to.
For anything that spans apps (setup, environments, deployment, secrets), read
`<root>/platform/`.

## Commands

    <app-specific build, run and test commands>

## Always-on rules

- <Rule>. (<scope>/NN)
```

In the root agent file, a scoped "Read before you touch" row names the scope or the doc:
`| Changing a migration | backend/40-database, platform/90-deployment |`.

## Link check (flat)

Run from the repository root; adjust the agent file name and the number width.

```python
import glob, os, re


def prose(text):
    """The text without code blocks and code spans, whose links are examples."""
    return re.sub(r'`[^`\n]*`', '', re.sub(r'```.*?```', '', text, flags=re.S))


def contents_ok(text):
    """The Contents list links every ## and ### heading, in order, by its GitHub anchor."""
    body = re.sub(r'```.*?```', '', text, flags=re.S)
    section = re.search(r'^## Contents\n(.*?)^## ', body, flags=re.S | re.M)
    if not section:
        return False
    headings = [h for h in re.findall(r'^#{2,3} (.+)$', body, flags=re.M) if h != 'Contents']
    anchors = [re.sub(r'[^\w\- ]', '', h.lower()).replace(' ', '-') for h in headings]
    return re.findall(r'\]\(#([^)]+)\)', section.group(1)) == anchors

files = glob.glob('docs/*.md') + ['README.md', 'CLAUDE.md']
bad = 0
for f in files:
    if not os.path.exists(f):
        continue
    for m in re.finditer(r'\]\(([^)#\s]+)(#[^)]*)?\)', prose(open(f).read())):
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
    if not contents_ok(open(f).read()):
        print('contents out of date', b); bad += 1
print('problems:', bad)
```

## Link check (scoped)

Run from the repository root; set `ROOT` to the docs root.

```python
import glob, os, re


def prose(text):
    """The text without code blocks and code spans, whose links are examples."""
    return re.sub(r'`[^`\n]*`', '', re.sub(r'```.*?```', '', text, flags=re.S))


def contents_ok(text):
    """The Contents list links every ## and ### heading, in order, by its GitHub anchor."""
    body = re.sub(r'```.*?```', '', text, flags=re.S)
    section = re.search(r'^## Contents\n(.*?)^## ', body, flags=re.S | re.M)
    if not section:
        return False
    headings = [h for h in re.findall(r'^#{2,3} (.+)$', body, flags=re.M) if h != 'Contents']
    anchors = [re.sub(r'[^\w\- ]', '', h.lower()).replace(' ', '-') for h in headings]
    return re.findall(r'\]\(#([^)]+)\)', section.group(1)) == anchors

ROOT = 'docs'
skip = ('node_modules', '.git', '.next')
agent_files = [f for f in glob.glob('**/CLAUDE.md', recursive=True)
               if not any(s in f.split(os.sep) for s in skip)]
docs = glob.glob(f'{ROOT}/**/*.md', recursive=True)
bad = 0
for f in docs + agent_files + ['README.md']:
    if not os.path.exists(f):
        continue
    for m in re.finditer(r'\]\(([^)#\s]+)(#[^)]*)?\)', prose(open(f).read())):
        target = m.group(1)
        if target.startswith(('http', '/')):
            continue
        if not os.path.exists(os.path.join(os.path.dirname(f), target)):
            print('broken', f, target); bad += 1
scopes = sorted(d for d in os.listdir(ROOT)
                if os.path.isdir(os.path.join(ROOT, d)) and not d.startswith('.'))
index = open(f'{ROOT}/index.md').read() if os.path.exists(f'{ROOT}/index.md') else ''
for scope in scopes:
    overview = glob.glob(f'{ROOT}/{scope}/00-*.md')
    if not overview:
        print('no overview in', scope); bad += 1
        continue
    if f'{scope}/00-' not in index:
        print('index.md misses scope', scope); bad += 1
    text = open(overview[0]).read()
    for f in sorted(glob.glob(f'{ROOT}/{scope}/*.md')):
        b = os.path.basename(f)
        if not b.startswith('00-') and b not in text:
            print('not in overview', f); bad += 1
        if not contents_ok(open(f).read()):
            print('contents out of date', f); bad += 1
for f in agent_files:
    for scope, num in re.findall(r'\b([a-z][a-z0-9-]*)/(\d{2})\b', open(f).read()):
        if scope in scopes and not glob.glob(f'{ROOT}/{scope}/{num}-*.md'):
            print(f, 'names missing doc', f'{scope}/{num}'); bad += 1
print('problems:', bad)
```
