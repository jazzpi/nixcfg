# nixcfg

Hi. This is my NixOS & home-manager configuration.

## Structure

- [`flake.nix`](./flake.nix) is the root flake for NixOS / home-manager /
  packages
- [`modules`](./modules/) contains my custom modules for configuring programs /
  features. These modules expose options in the `j` namespace.
- [`hosts`](./hosts/) contains the actual host configurations. These use the
  modules via the `j.*` options.
- [`packages`](./packages/) contains some custon Nix packages.
- [`shells`](./shells/) contains flakes with dev shells for various languages.
  If you install the home-manager config, you can use these in a folder (through
  direnv) by running `use-dev-flake NAME`.
- [`util`](./util/) contains Nix helper functions.
- [`dotfiles`](./dotfiles/) contains verbatim dotfiles (some of these are
  templated via [Mustache](https://mustache.github.io/)).
- [`bin`](./bin/) contains some scripts that are installed into `$PATH` through
  the home-manager config.
- [`assets`](./assets/) contains media assets (at the moment, only wallpapers).
- [`private`](./private/) is a submodule with configuration I don't want to be
  publically available (e.g. SSH hosts).

## Usage

If you stumble across this and are asking yourself if you should use NixOS --
let [hlissner answer that
question](https://github.com/hlissner/dotfiles/?tab=readme-ov-file#frequently-asked-questions):

> **Should I use NixOS?**
> 
> **Short answer:** no.
> 
> **Long answer:** no really. Don't.
> 
> **Long long answer:** I'm not kidding. Don't.
> 
> **Unsigned long long answer:** Alright alright. Here's why not:
> 
> - Its learning curve is steep.
> - You _will_ trial and error your way to enlightenment, if you survive the
> frustration long enough.
> - NixOS is unlike other Linux distros. Your issues will be unique and
> difficult to google. A decent grasp of Linux and your chosen services is a
> must, if only to distinguish Nix(OS) issues from Linux (or upstream) issues
> -- as well as to debug them or report them to the correct authority (and
> coherently).
> - If words like "declarative", "generational", and "immutable" don't put your
> sexuality in jeopardy, you're considering NixOS for the wrong reasons.
> - The overhead of managing a NixOS config will rarely pay for itself with 3
> systems or fewer (perhaps another distro with nix on top would suit you
> better?).
> - Official documentation for Nix(OS) is vast, but shallow. Unofficial
> resources and example configs are sparse and tend toward too simple or too
> complex (and most are outdated). Case in point: this repo.
> - The Nix language is obtuse and its toolchain is not intuitive. Your
> experience will be infinitely worse if functional languages are alien to
> you, however, learning Nix is a must to do even a fraction of what makes
> NixOS worth the trouble.
> - If you need somebody else to tell you whether or not you need NixOS, you
> don't need NixOS.
> 
> If you're not discouraged by this, then you didn't need my advice in the first
> place. Stop procrastinating and try NixOS!

### Provision host (with existing configuration)

```sh
nix-shell -p nh
export NIX_CONFIG="experimental-features = nix-command flakes"
# Rebuild NixOS
./rebuild -s HOSTNAME
# Rebuild home-manager
./rebuild -u USER@HOSTNAME
```

and reboot.

### Provision host (with new configuration)

1. Add a new host to the `hosts` attrset in [flake.nix](./flake.nix). The
   attribute name is the hostname.
2. Create a corresponding folder in [hosts/](./hosts/). Copy
   `/etc/nixos/hardware-configuration.nix` to this folder.
3. Create at least a `sys.nix` (NixOS config) and `home.nix` (home-manger
   config) in the folder. `common.nix` (if it exists) is added to both configs.
   Reference the existing hosts for how to structure your host config.

```sh
nix-shell -p nh
export NIX_CONFIG="experimental-features = nix-command flakes"
# Rebuild NixOS
./rebuild -s HOSTNAME
# Rebuild home-manager
./rebuild -u USER@HOSTNAME
```

and reboot.
