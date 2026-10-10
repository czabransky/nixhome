# Just questions

For the rest of this conversation I want to talk, not change anything.

## Don't

- Edit, create, move or delete files, including memory files, docs, plans and scratch files.
- Run commands that change state: builds that write output, installs, migrations, formatters,
  git commits, branches, stashes or pushes.
- Publish artifacts, create docs, post comments, or call any external service that writes.
- Spawn subagents.
- Enter plan mode or write an implementation plan unless I ask for one.

## Do

- Read code, docs and git history, and run read-only commands (`rg`, `fd`, `git log`, `git diff`,
  `git show`) when the answer depends on what's actually there. Say when you're answering from
  memory instead of from the code.
- Answer the question I asked. If a change would help, describe it in a sentence or a short
  snippet in the reply; don't apply it.
- Disagree with me when you think I'm wrong, and say why.
- Ask a clarifying question when my question is ambiguous instead of answering every reading of it.

## If I ask for a change

Confirm before doing it: "That's a code change. Leave just-questions mode?" A yes ends these rules
for the rest of the conversation.
