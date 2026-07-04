# `types.path` accepts derivations, but `lib.isPath` does not

A module option typed `path` (or `either lines path`) will **accept a derivation** you pass
in, because `types.path.check` only requires the value to be *coercible to a `/…` string*
— and a derivation stringifies to its `/nix/store/...` outPath. So the option's type check
passes and gives you false confidence.

But module *implementation* code frequently branches on **`lib.isPath`** (= `builtins.isPath`),
which is true **only for a real `path`-type value**. A derivation is an attrset, so
`lib.isPath drv == false`. The two notions of "path" disagree:

| value | `types.path.check` | `lib.isPath` |
|---|---|---|
| `./foo` (path literal) | ✓ | ✓ |
| `"/nix/store/…"` (string) | ✓ | ✗ |
| derivation | ✓ (via outPath) | ✗ |

## Consequence / symptom
You pass a derivation to an option; the type accepts it; then the module's `config` block
routes it down the wrong branch (e.g. a "not a path → treat as inline `text`" fallback),
and you get a type error *further down*, on some internal option, that names your
derivation. **The error location is not where you set the option.**

Concrete case in this repo: `programs.claude-code.agents` is typed `either lines path`, so a
`templateFile` derivation passed the type check — but the module's `mkSourceEntry` uses
`lib.isPath`, sent the derivation to its `text` branch, and `home.file.<>.text` (`types.lines`)
rejected it. See [[home-manager/claude-code]].

## Rule of thumb
When passing a **non-trivial value** (derivation, generated/templated path, structured
attrs) to an option, **read the option's `config` block**, not just its type — the type can
accept a value the implementation then mishandles. To feed generated *content*, prefer a
plain string (`builtins.readFile drv`, which is [[import-from-derivation]]) or a genuine
path literal, matching whatever the `config` branch actually checks.
