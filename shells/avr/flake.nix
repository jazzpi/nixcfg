{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          # TODO: Extract general C++ dependencies to a separate flake/module
          # (cmake, clang-tools, whatever's in home/programming/cpp.nix etc.)
          nativeBuildInputs = [
            llvmPackages_19.clang-tools
            # pkgconf
            # pkg-config
            cmake
            # gdb
            pkgsCross.avr.buildPackages.gcc
          ];
          hardeningDisable = [ "all" ];
        };
      }
    );
}
