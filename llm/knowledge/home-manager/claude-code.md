# programs.claude-code

- **Source rev:** 74b3817 (flake-locked home-manager)
- **Key files:** `modules/programs/claude-code.nix`

## `agents` / `commands` / `rules` / `outputStyles` — content options
Typed `attrsOf (either lines path)` via `mkContentOption`. The attr **name becomes the
filename**: `agents.foo` → `~/.claude/agents/foo.md` (`.claude/${subdir}/${name}.md`, ~line
523). Value is either inline markdown (string, with frontmatter) or a path to such a file.

**Gotcha:** the config uses `mkSourceEntry = content: if lib.isPath content then { source =
content; } else { text = content; }` (~line 515). A **derivation is not `lib.isPath`**, so
it falls into the `text` branch and `home.file.<>.text` rejects it — even though the option
*type* `path` accepted it. See [[nix/types-path-accepts-derivations-but-ispath-does-not]].
→ To supply generated content, pass a **string** via `builtins.readFile (templateFile …)`,
not the derivation. (This repo does exactly that in `modules/home/programming/llm.nix`.)

## `mcpServers`
Typed `attrsOf <json>`. **Not** written to `~/.claude/`. The module bundles them into a
generated home-manager *plugin*: it writes `.mcp.json` into a `claude-code-hm-plugin` dir
and wraps `cfg.package` with `--plugin-dir <that dir>` (~lines 596–626), exposed as
`finalPackage`. So MCP config rides inside the wrapped `claude` binary, not a dotfile —
grepping `~/.claude/` for it finds nothing. Requires `package != null`.

## `skills`
A directory path (not an attrset): `skills = "<dir>"` symlinks each `<dir>/<name>/SKILL.md`
into `~/.claude/skills/`. Distinct from the content options above.

## Store-symlink caveat (devcontainers)
`agents`/`skills` land as symlinks into the nix store. If `~/.claude` is bind-mounted into a
container, those symlinks dangle. This repo's `llm.nix` has an activation hack that
dereferences `skills` + merges `settings.json`, but **not** `agents` — acceptable because
the research agents reference host-only paths anyway.
