---
description: Update CLAUDE.md based on code changes since it was last edited
argument-hint: [optional instructions]
---

Update CLAUDE.md to reflect recent code changes.

## Steps

1. Run `git log -1 --format="%H" -- CLAUDE.md` to find the last commit that touched CLAUDE.md.

2. Use that hash to get all changes since then:
   - `git log --oneline <hash>..HEAD`
   - `git diff <hash>..HEAD --stat`

3. Read the current CLAUDE.md and the full diff of relevant changed files to understand what has actually changed.

4. Edit CLAUDE.md in-place: add sections for new patterns/binaries/modules, update sections that are now inaccurate, and remove sections that no longer apply. Preserve existing structure, voice, and formatting. Only change what the git history justifies.

If the user provided additional instructions, apply them: $ARGUMENTS
