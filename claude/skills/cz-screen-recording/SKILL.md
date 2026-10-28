---
name: cz-screen-recording
description: Find the user's latest macOS screen recording in ~/Documents and review it by extracting frames with ffmpeg. Use when the user mentions a screen recording, "my recording", "the recording", "check my recording", "watch this", or "look at the video" without giving a path. Always picks the most recent recording unless the user names a specific file or time.
---

# Screen recording review

macOS saves screen recordings to `~/Documents/` as `Screen Recording YYYY-MM-DD at H.MM.SS AM.mov`.
The space before AM/PM is a narrow no-break space (U+202F), so never type a filename by hand: use
a glob or the path the commands below print.

## Step 1: Find the recording

Pick the newest by modification time:

```sh
ls -t ~/Documents/Screen\ Recording*.mov | head -1
```

If the user named a date, time or file, match that instead. Tell the user which file you picked
(name and timestamp) before reviewing it.

## Step 2: Extract frames

Claude can't read video directly. Get the duration, then extract frames into the scratchpad:

```sh
ffprobe -v error -show_entries format=duration -of csv=p=0 "<file>"
```

Spread about 30 frames evenly (`fps=30/<duration>`), capped at `fps=10` for clips under 3 s.

```sh
mkdir -p <scratchpad>/recording
ffmpeg -v error -i "<file>" -vf "fps=<rate>,scale=1280:-2" <scratchpad>/recording/frame_%03d.png
```

If the user asks about a specific moment, extract denser frames around it with `-ss <start> -t <length>`
before `-i`. Frame `n` at rate `r` is at roughly `(n - 1) / r` seconds; use that to give timestamps.

## Step 3: Review

Read the frames in order with the Read tool. Answer what the user asked about the recording, citing
timestamps for what you saw (e.g. "at 0:12 the dialog closes before the save finishes"). If the user
gave no specific question, describe what happens step by step and point out errors, glitches or
unexpected UI states.
