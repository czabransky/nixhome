---
name: cz-deslop
description: Review and rewrite existing text for AI writing patterns (inflated significance, "serves as" phrasing, trailing -ing commentary, AI-typical and promotional vocabulary, "not X but Y" constructions, reflexive triplets, synonym cycling, Title Case, bold-label lists, emoji formatting, em dashes, chatbot openers and closers, boilerplate hedges, procedural summaries). Works on UI strings and locale files, error messages, READMEs and docs, PR descriptions, commit messages, code comments, and pasted text. Use when the user asks to deslop or de-AI text, make it sound less AI-generated, clean up copy or UI strings, or review writing for AI tells. Do NOT use for code-correctness review (use code-review) or for restructuring a project's docs (use cz-numbered-docs).
---

# Deslop

Find AI writing patterns in text that already exists and rewrite them plainly. The rules are the
`## Writing` section of the global CLAUDE.md. `references/patterns.md` has the full catalog with
before/after rewrites; read it before starting.

## Step 1: Pin down the target

- Files or globs the user named, pasted text, a PR body (`gh pr view <n> --json title,body`),
  commit messages on the branch (`git log main..HEAD --format=%B`), or the current diff.
- For "the UI strings" with no path, find them: locale files first (`locales/`, `i18n/`, `*.po`,
  `*.resx`, `*.strings`, translation JSON), then user-facing string literals in components. If
  that's more than a handful of files, confirm the list with the user.
- In code, only prose is in scope: user-facing string literals, comments, docstrings, log and
  error messages. Never rename identifiers, translation keys, or API fields.

## Step 2: Mechanical sweep

Run this over the target to catch word-level tells:

```sh
rg -n -i '—|\b(delv(e|es|ing)|crucial|pivotal|vital|tapestry|testament|intricate|interplay|meticulous(ly)?|vibrant|robust|seamless(ly)?|effortless(ly)?|cutting-edge|foster(s|ing)?|enhanc(e|es|ing)|elevat(e|es|ing)|empower(s|ing)?|unlock(s|ing)?|harness(es|ing)?|leverag(e|es|ing)|streamlin(e|es|ing)|showcas(e|es|ing)|underscor(e|es|ing)|comprehensive|nuanced|realm|journey|landscape|serves as|stands as|functions as|boasts)\b|\bnot (just|only)\b|\bit.s not\b|absolutely right|great question|hope this helps|let me know if|feel free to|it.s (important|worth) (to note|noting|mentioning)|\bin (summary|conclusion)\b|despite these challenges|looking ahead|\boops\b' <paths>
```

For pasted text, write it to a scratch file first. A hit is a lead, not a verdict: skip literal
uses such as unlocking a mutex, a robust estimator, landscape orientation, or a key in code.

## Step 3: Read for structural patterns

The sweep can't see these. Read the whole target for:

- Trailing -ing clauses that editorialize ("..., highlighting the need for X").
- Triplets where the real count is two or four.
- Negative parallelisms without trigger words ("less about X, more about Y", "X rather than Y").
- Significance inflation and vague attribution.
- Synonym cycling: one thing called "workspace", "project", and "space" on different screens.
- Title Case buttons and headings, bold-label lists, emoji used as bullets or decoration.
- Openers, closers, recaps, boilerplate caveats, and "ensured/preserved" process summaries.

## Step 4: Report

One table, ordered by file then line:

| Location | Pattern | Original | Rewrite |
| --- | --- | --- | --- |

Group repeats in a long target ("14 buttons in Title Case") instead of listing each one. If the
user asked only for a review, stop here and offer to apply the rewrites.

## Step 5: Rewrite

When the user asked for changes:

- Keep the meaning. Concrete details in a rewrite must come from the code or the user; if the
  original is vague and you don't know the specifics, cut it or ask. Never invent numbers or
  features. If a sentence was only filler, delete it.
- Same length or shorter.
- Don't swap a flagged word for a synonym ("crucial" to "vital"). Rewrite the sentence.
- Match the voice of the surrounding copy that isn't flagged.
- Leave correct formal grammar and the occasional transition word alone.
- Locale files: change only the source language unless asked, and list the keys whose
  translations may now be out of step.
- Commit messages can't change without rewriting history, and PR descriptions are shared. Show
  the rewrite; amend, rebase, or run `gh pr edit` only when the user asks.

## Step 6: Verify

- Rerun the Step 2 sweep on the changed files. Each remaining hit should be a literal use you
  chose to keep.
- If UI strings changed, run the project's tests: snapshot and string-matching tests often assert
  exact copy. Update expectations that only encoded the old wording; report other failures
  verbatim.
- Report changes by file, then the hits you left alone and why.
