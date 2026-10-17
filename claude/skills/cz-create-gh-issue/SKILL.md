---
name: cz-create-gh-issue
description: Create a new GitHub issue with `gh`, after settling every fact in it with the codebase or the user, following the repo's issue templates and image instructions, and checking open issues and PRs for duplicates and overlapping work (adding a "Depends on #X" line when the new issue would touch the same files). Use when the user says "create an issue", "gh issue", "github issue", "issue", or "ticket", or asks to open, file, or write up a bug report or feature request. Also use when the user asks to "create a PR" for work that has no issue yet: push back and create the issue first. Do NOT use for commenting on or editing an existing issue, or when the user names Jira or another tracker for the ticket.
---

# Create a GitHub issue

Draft an issue whose every claim is either verified or confirmed by the user, check it against
ongoing work, get approval, then create it. Never run `gh issue create` before the user approves
the final draft.

## Requests to create a PR

When the user asks to create a PR, check whether the work already has an issue: look for an issue
number in the branch name, commit messages, or the conversation, and search open issues for it.

- If an issue exists, this skill doesn't apply. Open the PR and reference that issue.
- If none exists, push back: say the work needs an issue first so the overlap check in Step 4
  runs and the PR has an issue to close. Offer to create it with this skill. Once the issue
  exists, the PR body references it (`Closes #<n>`).
- If the user still wants the PR without an issue, stop this skill and leave the PR to them.

## Step 1: Identify the repo and its conventions

- Confirm the target repo with `gh repo view --json nameWithOwner,url`. If the user named a
  different repo, use `-R <owner>/<repo>` on every `gh` command.
- Read the issue templates if they exist: `.github/ISSUE_TEMPLATE/*`, `.github/ISSUE_TEMPLATE.md`,
  `ISSUE_TEMPLATE.md`. Pick the template that fits and keep its headings and required fields.
- Read the repo's agent and contributor instructions: `CLAUDE.md` (root and nested), `AGENTS.md`,
  `CONTRIBUTING.md`, `.github/*.md`, `.claude/skills/`, `.claude/commands/`, and `docs/`.
- Search those for instructions on images and attachments:

  ```sh
  rg -n -i 'screenshot|image|attach|upload|\.png|\.jpe?g|\.gif' -g '*.md' -g '*.yml' -g '*.yaml' .github CLAUDE.md AGENTS.md CONTRIBUTING.md docs .claude
  ```

  Ignore paths that don't exist. Note any instructions on where images go and how the issue
  references them.
- List existing labels with `gh label list --limit 200`. Only apply labels that already exist.

## Step 2: Settle the facts

Write down every factual claim the issue will make: file paths, function and component names,
current behavior, expected behavior, error messages, reproduction steps, versions, environment,
and scope.

- Verify each one you can against the code, git history, logs, or by running a command. Correct
  anything the user said that the code contradicts, and tell them what you found.
- Collect the claims you can't verify, and anything ambiguous about scope or intent, and ask the
  user about them in one batch with `AskUserQuestion`. Don't fill gaps with guesses: no invented
  reproduction steps, versions, or expected behavior.
- Repeat until no claim is unsettled.
- Record the files and directories the fix or feature would most likely touch. Step 4 needs them.

## Step 3: Check for duplicates

Search open issues and PRs for the same problem:

```sh
gh issue list --state open --search '<keywords>' --json number,title,url
gh pr list --state open --search '<keywords>' --json number,title,url
```

Try two or three keyword sets (error text, component name, user-facing symptom). If one looks like
the same problem, stop and show it to the user. Continue only if they say the new issue is
distinct.

## Step 4: Check for overlapping work

A new issue depends on ongoing work when doing it would touch the same files, or would otherwise
cause a merge conflict with that work (for example, both rename or restructure the same module,
or both change the same schema or config).

Open PRs, with the files they change and the issues they close:

```sh
gh pr list --state open --limit 100 --json number,title,headRefName,files,closingIssuesReferences
```

Open issues (all of them, assigned or not):

```sh
gh issue list --state open --limit 200 --json number,title,body,labels
```

- For each PR, compare its `files` with the files from Step 2.
- For each issue, judge from its title and body which files or areas it would touch, and compare.
  Search the code for names it mentions when the body doesn't name files.
- For an overlapping PR, X is the issue it closes (`closingIssuesReferences`). If it closes none,
  X is the PR number. If it closes several, use each one that overlaps.
- Drop duplicate numbers, such as an issue found directly and again through its PR.

Every overlap goes in the body as one line, comma-separated:

```
Depends on #12, #15
```

Put it on its own line at the end of the body. This line is required whenever an overlap exists.

## Step 5: Handle images

If the user provided images:

- If the repo has instructions for images (Step 1), follow them. If they involve pushing a commit,
  uploading to a service, or anything else outward-facing, include that step in the draft so the
  user approves it with the issue.
- Otherwise, read each image and describe in the body what it shows that matters to the issue
  (the error text, the wrong state, the layout problem). Quote visible error text exactly. Don't
  attach the image.

## Step 6: Draft and get approval

Write the draft to a scratch file and show the user:

- Title.
- Body, following the template from Step 1, with the "Depends on" line if Step 4 found overlaps.
- Labels, assignees, and milestone, if any.
- The overlap findings: each dependency and the files or area it shares, plus any close calls you
  left out and why.

Write the body in the repo's existing issue voice and follow the global writing rules. Revise
until the user approves.

## Step 7: Create the issue

```sh
gh issue create --title '<title>' --body-file <scratch file> --label '<label>'
```

Report the issue URL.
