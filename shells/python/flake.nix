{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
        pythonPackages = with pkgs.python3Packages; [
          jupyter
          pip
          numpy
          pandas
          opencv-python
          scikit-learn
          matplotlib
        ];
        pythonNativeDeps = builtins.concatLists (map (pkg: pkg.buildInputs) pythonPackages);
      in
      with pkgs;
      {
        devShells.default = mkShell {
          nativeBuildInputs = [
            uv
            poetry
            pre-commit
            python3
            liblxi
          ]
          ++ pythonNativeDeps;
          hardeningDisable = [ "all" ];
        };
      }
    );
}
