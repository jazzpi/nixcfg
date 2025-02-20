{ lib, ... }:
{
  imports = [
    ./common.nix
    ./networking.nix
    ./programs.nix
    ./gui
    ./virt
  ];
}
