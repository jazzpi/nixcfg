# The defaults only apply outside the flake (e.g. nix-update without --flake),
# where the inputs have to be taken from flake.lock directly.
let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  input = name: builtins.fetchTree lock.nodes.${lock.nodes.root.inputs.${name}}.locked;
  mkPkgs = name: import ./util/mk-pkgs.nix (input name) "x86_64-linux";
in
{
  pkgs ? mkPkgs "nixpkgs",
  pkgs-stable ? mkPkgs "nixpkgs-stable",
}:
{
  oscarwatch = pkgs.callPackage ./packages/oscarwatch { };
  openocd-git = pkgs.callPackage ./packages/openocd-git { };
  stm32cubeprog = pkgs.callPackage ./packages/stm32cubeprog { };
  gr-satellites = pkgs-stable.callPackage ./packages/gr-satellites { };
  yamcs-studio = pkgs.callPackage ./packages/yamcs-studio { };
  pgplot = pkgs.callPackage ./packages/pgplot { };
  strf = pkgs.callPackage ./packages/strf { };
  sattools = pkgs.callPackage ./packages/sattools { };
  stvid = pkgs.callPackage ./packages/stvid { };
  astroimagej = pkgs.callPackage ./packages/astroimagej { };
  tlescope = pkgs.callPackage ./packages/tlescope { };
  claude-devtools = pkgs.callPackage ./packages/claude-devtools { };
}
