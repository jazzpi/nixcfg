# Research knowledge base

Distilled, hard-won findings about **Nix**, **home-manager** and **nixpkgs** internals.

## Why this exists
Option docs are often too shallow to implement complex config. The first deep-dive into the source is expensive; the researcher records what it found here so every later question on the same module is cheap. The agents themselves don't "learn" — this directory *is* their accumulated expertise.

## How it works
- These are **plain git-tracked files**, not nix-store symlinks, so the agents can append to them and the writes persist.
- Every addition shows up in `git diff`. **You are the review gate:** read what a researcher recorded, correct anything wrong, let the user commit. Only committed notes are trusted long-term.
- Each note cites the source `git rev` it was verified against, so stale notes are detectable after a `./update`.

## Layout
- `nix/` — one file per topic
- `home-manager/` — one file per module/topic (e.g. `programs-foo.md`)
- `nixpkgs/` — one file per module/package/lib topic

Notes cross-link with `[[note-name]]`.
