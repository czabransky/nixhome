# AI writing patterns

Adapted from Wikipedia's "Signs of AI writing" (WP:AISIGNS), plus UI copy tells. Each entry lists
what to look for, then before → after. The rewrites assume the concrete detail is known from the
code or the user; without it, cut the sentence instead of inventing specifics.

## Content

### Inflated significance

Claims that something matters instead of saying what it does: "plays a crucial/pivotal/vital
role", "serves as a testament/reminder", "underscores the importance of", "marks a turning
point", "reflects broader trends", "sets the stage for", "evolving landscape", "indelible mark",
"deeply rooted".

- The cache plays a crucial role in ensuring optimal performance. → The cache saves a database
  read on every request.
- This release marks a pivotal step in our accessibility journey. → This release adds keyboard
  navigation to every dialog.

### Editorializing -ing clauses

A participle clause tacked on to interpret the sentence: highlighting, underscoring,
emphasizing, ensuring, reflecting, symbolizing, contributing to, fostering, showcasing,
enhancing.

- Added retry logic to the uploader, ensuring a seamless experience for users. → Added retry
  logic to the uploader.
- The team migrated to Postgres, reflecting a commitment to reliability. → The team migrated to
  Postgres.

### Promotional language

boasts, vibrant, rich, profound, showcasing, exemplifies, commitment to, groundbreaking,
renowned, diverse array, nestled, in the heart of. In product copy: seamless, effortless,
powerful, robust, supercharge, unlock, elevate, empower, next-level, world-class.

- Unlock the power of seamless collaboration. → Edit documents with your team in real time.
- Our robust export engine empowers you to effortlessly share insights. → Export any report as
  CSV or PDF.

### Vague attribution

"Experts argue", "industry reports suggest", "observers have noted", "it is widely considered",
"many developers find", "several sources". Name the source or delete the claim.

### Challenges-and-outlook endings

A closing paragraph of obstacles followed by optimism: "Despite its X, it faces several
challenges", "Despite these challenges", "Looking ahead", "Future outlook". Delete it, or replace
it with the specific open items.

## Language

### AI vocabulary

Words that cluster in generated text. Earlier models: additionally, boasts, bolstered, crucial,
delve, emphasizing, enduring, garner, intricate, interplay, key, landscape, meticulous, pivotal,
underscore, tapestry, testament, valuable, vibrant. Later models: align with, enhance, fostering,
highlighting, showcasing. One hit in plain text is weak evidence; several in a paragraph is
strong. Rewrite the sentence rather than substituting a synonym.

### Copula avoidance

"serves as", "stands as", "functions as", "acts as", "represents", "boasts", "features",
"offers" where "is" or "has" would do.

- The settings page serves as the central hub for configuration. → All configuration is on the
  settings page.
- The dashboard boasts three views. → The dashboard has three views.

### Negative parallelism

"It's not X, it's Y", "not just X, but also Y", "not only... but", "less about X, more about Y",
or "Y rather than X" when nobody claimed X. Keep it when it corrects something someone actually
said.

- This isn't just a todo app. It's a productivity system. → Track tasks and recurring chores.
- Deploys are less about speed and more about safety. → Deploys wait for health checks before
  shifting traffic.

### Rule of three

Adjective triplets and three-part phrase lists used for rhythm: "fast, reliable, and secure",
"contemporary values, modern aesthetics, and digital animation technology". Use the real number
of items; two is fine, and so is one.

### Synonym cycling

Rotating names for one referent to avoid repetition: "the user", "the customer", "the account
holder"; "workspace", "project", "space". Pick one term and repeat it. In a UI, different labels
make users think they're different things.

## Style and formatting

### Em dashes

Especially spaced " — " asides and several per paragraph. Wikipedia's comparison found Claude
uses them more than professional writers. Replace with a period, comma, colon, or parentheses.

- Sync runs hourly — or on demand — so your data stays current. → Sync runs hourly. You can also
  run it on demand.

### Title Case

Headings, buttons, menu items, and tabs in Title Case in a project that uses sentence case.

- Manage Your Account Settings → Manage account settings

### Bold and inline-header lists

Bold scattered through prose, and lists where every item is "**Label**: explanation". Use prose
or a plain list. Bold only a term the reader must not miss.

### Emoji as formatting

Emoji as bullets, heading decoration, or button prefixes: "🚀 Get started", "✅ Saved!",
"🎯 What I'm working on". Remove unless the product already uses them.

### Heading misuse

A heading on a three-sentence answer, a first heading that repeats the title, parent headings
with only subheadings under them, skipped levels.

### Curly quotes

Curly quotes and apostrophes in code, config, or markup where the file otherwise uses straight
quotes.

### Chatbot markup leftovers

Text pasted from another assistant can carry its citation markup: "contentReference",
"oaicite", "turn0search0", "[cite: 1]", "attached_file". Delete it.

## Communication aimed at the reader

### Openers and closers

"Great question!", "Certainly!", "Of course!", "You're absolutely right!", "I hope this helps",
"Let me know if you have any questions", "Would you like me to...", "Feel free to", "Here is a
...". In product copy: "Welcome aboard!", "Oops!", "Uh oh!", "You're all set! 🎉".

### Boilerplate hedges

"It's important to note", "It's worth mentioning", "Based on the available information", "While
specific details are limited", "not widely documented". Replace with the specific caveat
("untested on Windows") or delete.

### Recaps

"In summary", "Overall", "In conclusion", and closing paragraphs that restate the body. Delete.

### Placeholders

Unfilled template text in shipped copy: "[Your Name]", "[Specific Topic]", "2025-XX-XX", lorem
ipsum, "TODO: add description".

### Procedural summaries

Commit messages, PR bodies, and changelogs that describe virtues of the process instead of the
change: "preserved existing behavior", "retained", "ensured consistency", "avoided breaking
changes", "improved clarity and readability", "comprehensive refactor". Say what changed and,
when it isn't obvious, why.

- Refactored the auth module to improve readability and maintainability while preserving
  existing behavior. → Split auth.ts into session.ts and tokens.ts.

## UI copy

- Buttons name the action: "Save", "Delete file". Not "Let's go!" or "Submit Your Request".
- Errors say what failed and what to do next. "Oops! Something went wrong. Please try again
  later." → "Couldn't upload report.pdf: files must be under 25 MB."
- Empty states say what's missing and how to add it. "✨ Your journey starts here!" → "No
  invoices yet. Create one from Billing."
- Success messages are short. "Success! Your changes have been saved successfully! 🎉" →
  "Saved".
- Help text and tooltips: one sentence on what the control does.

## Not AI patterns

Leave these alone when they appear by themselves:

- Correct grammar and a formal or technical register.
- A single plain transition such as "Additionally" or "However".
- Mixed casual and formal tone.
- Missing citations.
- Simple constructions ("there is", "it has") and plain verbs ("wrote" rather than "authored").
  These read as human; prefer them in rewrites.
