# emacsWithPackages / emacsPackagesFor: load-path mechanism and `-Q` interaction

- **Source rev:** a410086c5c00
- **Key files:**
  - `pkgs/applications/editors/emacs/build-support/wrapper.nix` — builds a merged
    `site-lisp` tree (`lndir` of every transitive dependency's `share/emacs/site-lisp`)
    plus a generated `site-start.el` and `subdirs.el`, then wraps every binary from the
    base `emacs` derivation with `wrapper.sh`.
  - `pkgs/applications/editors/emacs/build-support/wrapper.sh` — the actual wrapper:
    computes `EMACSLOADPATH` (prepending the merged site-lisp dir, or inserting it at the
    position of an existing empty `::` segment if the caller already set
    `EMACSLOADPATH`) and `EMACSNATIVELOADPATH`, exports both, then `exec`s the real
    `emacs` binary.

## Findings

1. **Mechanism:** package availability is delivered purely via the `EMACSLOADPATH` /
   `EMACSNATIVELOADPATH` environment variables, exported by the wrapper *before* `exec`ing
   the real Emacs binary (`wrapper.sh:47-56`). There is no `--eval`/`-l` flag baked into
   the wrapper and no reliance on `package.el`/`package-initialize`.
   - `site-start.el` is also generated and placed in the merged site-lisp dir
     (`wrapper.nix:160-186`), but it only re-loads the base Emacs's original
     `site-start.el` and adds `$out/bin` to `exec-path` (and `native-comp-eln-load-path`
     if native comp is enabled) — it does **not** add anything to `load-path` itself;
     `load-path` is already correct via `EMACSLOADPATH`.
2. **`-Q` interaction:** `-Q` = `--no-init-file --no-site-file --no-site-lisp
   --no-splash --no-x-resources`. `--no-site-file`/`--no-site-lisp` only suppress GNU
   Emacs's *own* startup logic for auto-loading `site-start.el`/default site-lisp dirs —
   they do not affect `EMACSLOADPATH`, which core Emacs startup uses directly to seed
   `load-path` regardless of those flags (documented GNU Emacs behavior, not nixpkgs
   code). Since the nixpkgs wrapper sets `load-path` availability entirely through
   `EMACSLOADPATH` (set in the shell wrapper, before the Emacs process even starts), **`-Q`
   does not break `(require 'package)` for anything from `emacsWithPackages`.**
   - The one thing `-Q` *does* lose is the generated `site-start.el`'s
     `(add-to-list 'exec-path "$out/bin")` and eln-path addition, since loading
     `site-start.el` is gated by `--no-site-file`. This only matters if a selected
     package ships an executable in its `bin/` output (rare for pure elisp packages like
     `magit`/`evil`/`evil-collection`) or if native compilation matters and you need the
     eln dir on `native-comp-eln-load-path`.
3. **No autoload generation:** neither `wrapper.nix` nor the package builders
   (`generic.nix`, `melpa.nix`, `elpa.nix`) generate `*-pkg-autoloads.el` or call
   `package-generate-autoloads`/`package-initialize` — that's a `package.el`-specific
   mechanism nixpkgs doesn't use. Packages are exposed as raw (byte-compiled) `.el`
   files on `load-path` via the merged site-lisp tree, so `(require 'PACKAGE)` (or
   autoload cookies a package itself defines and you trigger by calling a function) is
   the correct/necessary way to load them — there's no free autoloading of top-level
   entry points beyond what each package's own `-autoloads.el` (if it ships one) provides
   once required.

## Recommendation for a minimal Magit+evil setup

`-Q` is safe and sufficient: `emacs -nw -Q -l init.el ...` will have `magit`, `evil`,
`evil-collection`, and their transitive deps (`transient`, `with-editor`, `dash`, `seq`,
`compat`, `goto-chg`, etc.) on `load-path` via `EMACSLOADPATH`, so explicit
`(require 'magit)` / `(require 'evil)` / `(require 'evil-collection)` calls in `init.el`
work unmodified. No need for `-q --no-site-file` or any other combination — `-Q` is
strictly cleaner (also skips X resources/splash) with no functional downside here since
none of these three packages ship a `bin/` executable that would need
`site-start.el`'s `exec-path` addition.
