---
name: commit-coauthored
description: Writes a commit message for changes co-authored by Claude and the user.
---

Claude and the user have collaborated on a change to a codebase. Now we need to write a commit message for the combined changes.

## Steps

### 1. Verify the user staged the changes

Ask the user to confirm they have staged the changes they want to commit. If not, prompt them with "Stage the changes you want to include in the commit, or tell me to stage all changes for you." Then wait for their confirmation or instruction.

### 2. Retrieve the staged changes

Run `git diff --cached` to get the diff of the staged changes.

### 3. Summarize the changes

Use your context and the diff (in case the user made changes that you don't have context on) to write a concise summary of the changes. Follow project-specific instructions, or default to conventional commits (w/ Angular convention types) style with a concise header (max 80, but try to keep it under 50), an optional body with more details, and a footer with at least BREAKING CHANGE notes & a `Co-authored-by: Claude MODEL VERSION <noreply@anthropic.com>` line.
