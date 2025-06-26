{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        python = pkgs.python3.withPackages (
          ps: with ps; [
            jupyter
            pip
            numpy
            pandas
            opencv-python
            scikit-learn
          ]
        );
      in
      with pkgs;
      {
        devShells.default = mkShell {
          nativeBuildInputs = [
            uv
            mypy
            poetry
            pre-commit
            python
          ];
          hardeningDisable = [ "all" ];
        };
      }
    );
}
