# Code style

## Code comments

Comments should state non-obvious *why*s, not *what*s — those should be apparent from the code
itself. Avoid writing comments that have a high risk of going stale (e.g. because they
reference other code that would not be updated together with the comment). Spelled out:

- Never cite another file by path+line number (`foo.py:75-80`, `#L42`). Line numbers drift
  the moment either file is edited, and the comment silently becomes wrong or misleading
  instead of erroring.
- Never justify a design choice by pointing at what another file currently does
  ("matches how X.py does it", "same path Y already uses"). That other file can change or
  be deleted without anyone touching this comment. State the actual constraint or tradeoff
  in this file's own terms — something a reader can verify by reading the code in front of
  them, with zero context about any other file.
- Don't cite implementation-plan or design-doc sections ("see D14", "phase 3 will..."). Those
  documents are workflow scaffolding, not part of the shipped system, and get deleted or go
  stale independently of the code.
- Before writing a comment that explains _why_, ask: will this sentence still be true and
  checkable a year from now, by someone with none of today's context? If it depends on
  another file's current contents, another team's plan, or a section number, don't write
  it that way — inline the underlying reasoning instead.
- Default to no comment. Only write one when the WHY is genuinely non-obvious from the code
  itself; never restate WHAT the code does.
- Comment length is proportional to how surprising the WHY is, not to how confident you
  want to sound. If the reasoning behind a line is the obvious/default choice (e.g. "use
  the library's high-level API instead of hand-rolling the protocol"), that needs zero
  justification, not a paragraph defending it against an alternative nobody would take
  seriously. Save the words for the non-obvious constraint. One clause beats one sentence
  beats one paragraph — write the shortest one that still lands.

_Note_: commit messages have no risk of going stale since they are pinned to history.
Referencing specific lines or implementation plans there makes sense (as long as the
referenced files are tracked).
