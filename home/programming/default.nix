{ lib, ... }:
{
  imports = [
    ./nix.nix
    ./cpp.nix
    ./git.nix
    ./direnv.nix
  ];

  options.j.programming.enable = lib.mkEnableOption "Programming support" // {
    default = true;
  };
}
