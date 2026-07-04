# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Key Commands

**Rebuild system/home configuration:**
```sh
./rebuild -s HOSTNAME          # NixOS system config
./rebuild -u USER@HOSTNAME     # home-manager config
./rebuild -s -u                # both (defaults to current host)
```
Requires `nh` to be installed (`nix-shell -p nh`). The repository must live at `~/nixcfg` for home-manager builds.

**Update all flake inputs and rebuild:**
```sh
./update
```

**Garbage collect old generations:**
```sh
./gc <older_than_days>
```

**Check a build without switching:**
```sh
nh os build .#HOSTNAME -- --impure --no-warn-dirty --accept-flake-config
nh home build .#USER@HOSTNAME -- --no-warn-dirty --accept-flake-config
```

## Architecture

### Flake structure
`flake.nix` defines four hosts (`nixos-vm`, `jasper-gos`, `jasper-desk`, `jasper-fw`), all `x86_64-linux` with user `jasper`. For each host it produces:
- `nixosConfigurations.<hostname>` via `mkNixosConfig`
- `homeConfigurations.<user>@<hostname>` via `mkHomeConfig`

Both builders load `modules/common` + their respective module tree + `private/` (a git submodule with private config) + the host-specific file.

### Module system
All custom options live under the `j.*` namespace, defined in `modules/common/default.nix`. Modules gate their `config` blocks on the corresponding `j.*` option with `lib.mkIf`.

| Path | Purpose |
|---|---|
| `modules/common/` | Shared option declarations (`j.*` namespace) |
| `modules/home/` | home-manager modules (loaded into every home config) |
| `modules/sys/` | NixOS system modules (loaded into every system config) |
| `hosts/<name>/sys.nix` | Host-specific NixOS config |
| `hosts/<name>/home.nix` | Host-specific home-manager config |
| `hosts/<name>/common.nix` | Optional: added to both sys and home (if the file exists) |

### `paths` helper
`flake.nix` exposes two path sets to all modules:
- `paths.store.*` — absolute Nix store paths (use for derivations)
- `paths.repo.*` — `~/nixcfg/...` paths (use for runtime references)

Keys: `shells`, `dots`, `dots-repo`, `bin`, `pkgs`, `assets`, `wallpapers`, `lib`, `llm`.

### Templating
`util/template-file.nix` is a helper that renders Mustache templates at build time using `mustache-go`. Call it as:
```nix
templateFile { name = "foo"; template = <path>; data = { ... }; asBin = true; }
```
The `templateFile` argument is available as a `specialArgs`/`extraSpecialArgs` in both NixOS and home-manager configs.

### Custom packages
`packages/` contains Nix package derivations exposed through the root flake as `packages.x86_64-linux.*`:
- `oscarwatch` — OscarWatch Tracker package
- `thermal-camera-redux` — Thermal camera package
- `yamcs-studio` — YAMCS Studio package
- `gr-satellites` — GR Satellites package
- `stm32cubeprog` — STM32CubeProgrammer package

These can be built with `nix build .#<package-name>` or installed via the home-manager config.

### dotfiles, bin, and shells
`dotfiles/` contains verbatim (and some Mustache-templated) config files. `bin/` contains scripts that are installed into `$PATH` via the home-manager config. `shells/` contains per-language dev-shell flakes used via `use-dev-flake <NAME>` (powered by direnv).

### Claude Code skills
`llm/skills/` contains custom Claude Code skills configured in this project:
- `changelog-generator` — Automatically creates user-facing changelogs from git commits
- `nix-upgrade-fix` — Analyzes nixpkgs/home-manager update warnings and proposes fixes
- `update-claudemd` — Updates CLAUDE.md based on recent code changes

These are custom extensions to Claude Code's capabilities.

### Claude Code config: declarative only
**Never configure Claude Code imperatively** — no `claude plugin install`, `claude plugin marketplace add`, hand-editing `~/.claude/settings.json`, etc. All persistent Claude Code configuration (plugins, marketplaces, MCP servers, skills, settings) is managed declaratively through `modules/home/programming/llm.nix`, then applied via `./rebuild -u`.

### Nix research agents & knowledge base
`modules/home/programming/llm.nix` wires up tooling for editing this config:
- **`mcp-nixos`** MCP server — fast search of NixOS/home-manager options and nixpkgs
  packages. Use it for the common case: does an option exist, what's its type/description.
- **`home-manager-researcher` / `nixpkgs-researcher`** subagents (`llm/agents/*.mustache`)
  — dispatch these for deep dives into the home-manager (`~/dev/home-manager`) or nixpkgs
  (`~/dev/nixpkgs`) source when option docs are too shallow to implement something.
- **`llm/knowledge/`** — a git-tracked knowledge base the agents grow over time:
  `home-manager/` and `nixpkgs/` are written by their respective researchers; `nix/` holds
  cross-cutting Nix/flake/`lib` semantics and is **maintained by the main agent** (the
  researchers read it read-only). Read the relevant bucket before researching; every note
  cites the source rev it was verified against. Additions surface in `git diff` for review.

**Working rule:** When passing a **non-trivial value** (derivation, generated/templated path, structured attrs) to an option, read the option's `config` block — not just its type/description — or dispatch a researcher.

### `private/` submodule
`private/` is a git submodule containing sensitive config (SSH hosts, work-specific settings, etc.). It must be initialized before rebuilding: `git submodule update --init --recursive`. The `rebuild` script checks for uninitialized submodules automatically.

## Adding a new host
1. Add an entry to the `hosts` attrset in `flake.nix`.
2. Create `hosts/<name>/` with at least `hardware-configuration.nix`, `sys.nix`, and `home.nix`.
3. Enable desired features via `j.*` options in those files.
