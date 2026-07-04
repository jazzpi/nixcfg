# Flakes only see git-tracked files

When a flake refers to its own source via `${./.}` / `self` / any path under the flake
root (e.g. `paths.store.* = "${./.}/<subdir>"` in this repo), the store copy of the flake
source contains **only files git knows about**. **Untracked files are invisible** — they
are silently excluded from the copied source, even though they exist in the working tree.

## Symptom
A build (often an IFD/templating derivation) fails with `no such file or directory` for a
file you can clearly `ls` in your working tree. The path in the error points into a
`/nix/store/...-source` copy, not your working dir.

## Fix
`git add` the new files (staging is enough — no commit required). Then re-run. A dirty
working tree is fine; the flake reads *tracked* files, staged or committed.

## Applies to
Any new file you reference through the flake source: modules, templates
(`llm/agents/*.mustache`), assets, `dotfiles/`, etc. If a freshly created file "doesn't
exist" during a build, check `git status` first.

Related: [[import-from-derivation]] (templating via `templateFile` is IFD and reads flake
source at build time).
