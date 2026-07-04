# general-nix knowledge

Cross-cutting Nix / flake / `lib` semantics that underpin config work but aren't tied to any single source repo (they live in the Nix binary itself or in `lib`).

**Ownership:** this bucket is maintained by the **orchestrator** (the main agent editing the config), not by the source-scoped research subagents. The researchers read these notes as read-only substrate; if one discovers a general fact, it flags it and the orchestrator records it here. This keeps `home-manager/` and `nixpkgs/` notes provenance-clean (each verified against its own checkout).

One file per topic, kebab-case. See `../README.md` for the general workflow.
