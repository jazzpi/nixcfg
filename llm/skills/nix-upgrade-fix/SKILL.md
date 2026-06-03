---
name: nix-upgrade-fix
description: Given a warning or error from a home-manager or nixpkgs update, finds the relevant upstream commit(s), explains what changed, and proposes a concrete fix for the user's config.
argument-hint: <warning or error text>
---

The user has pasted a warning or error from a home-manager or NixOS/nixpkgs build or switch. Your job is to find what upstream change caused it, explain it clearly, and propose (or apply) a fix to their config.

## Steps

### 1. Parse the warning

Extract:
- The **option path** (e.g. `programs.ssh.matchBlocks.obc-eth.extraOptions`)
- The **module name** (e.g. `ssh` → `modules/programs/ssh.nix` in home-manager)
- Whether this is **home-manager** or **nixpkgs/NixOS** (look for `home-manager` in the store path or option namespace)

### 2. Update the upstream repo

The repos are always at:
- `~/dev/home-manager` for home-manager warnings
- `~/dev/nixpkgs` for nixpkgs/NixOS warnings

Run `git pull` in the relevant repo before searching, so the history is up to date.

### 3. Find the relevant commit(s)

Navigate to the repo and run:

```bash
git log --oneline -- <module-file-path>
```

For home-manager, the module file is typically `modules/programs/<name>.nix` or `modules/services/<name>.nix`. Scan the recent commits for keywords like `deprecat`, `rename`, `RFC`, `settings`, `migrate`, or the option name itself.

Then inspect the most promising commit:

```bash
git show <hash> -- <module-file-path>
```

Read the commit message first — it often summarises the whole change. Then skim the diff for the deprecation warning string itself to confirm you found the right commit.

### 4. Understand the new API

Check the test files for the module (`tests/modules/programs/<name>/`) — especially any new `settings*.nix` or `renamed*.nix` test cases. These show the exact new syntax with realistic examples.

### 5. Explain and propose

Give the user:
1. **What changed** — one or two sentences: which commit, what it introduced, why the old option is deprecated.
2. **How to fix it** — a concrete before/after showing the rename/restructure needed, using their actual option names from the warning.

Then ask if they want you to apply the fix, or apply it directly if the context makes it obvious.

## Tips

- The nix store path in the warning (e.g. `/nix/store/abc123-source/modules/...`) identifies the exact source file but not the git commit. Use `git log` on the local clone instead.
- Deprecation warnings usually come from a single commit that adds a new option and marks the old one `visible = false` plus emits `lib.warn`. That commit's message almost always explains the migration.
- Test files in the repo are the fastest way to see the new API — they show working syntax, not just types.
- When an `attrsOf` option is renamed (e.g. `matchBlocks` → `settings`), the nested option names often change too (camelCase → PascalCase for upstream directive names). Check both.
- `lib.hm.dag.entryBefore`/`entryAfter` DAG ordering typically carries over unchanged to the new option.
