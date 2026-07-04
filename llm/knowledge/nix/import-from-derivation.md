# Import from derivation (IFD)

IFD = using the *contents* of a build output during evaluation. Any of these force a
derivation to build mid-eval and read its result:

- `builtins.readFile drv` / `builtins.readDir drv`
- `import drv`
- string-interpolating a derivation into a path that is then read

## When it's useful here
Rendering a template at build time and feeding the text back into a module:
`builtins.readFile (templateFile { ... })`. This is how `modules/home/programming/llm.nix`
turns a `.mustache` agent template into the string content `programs.claude-code.agents`
wants (see [[home-manager/claude-code]] for *why* a string, not the derivation).

## Caveats
- Allowed by default (`allow-import-from-derivation = true`), but it **serializes eval and
  build** — eval blocks until the derivation is realised. Fine for tiny renders; avoid for
  anything heavy.
- Some CI / `nix flake check --pure-eval` setups forbid IFD. Not an issue for this repo's
  normal `./rebuild`.

Related: [[flakes-only-see-tracked-files]] (the template file must be git-tracked or the
IFD build can't find it).
