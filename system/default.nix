{ lib, ... }:
{
  imports = [
    ./common.nix
    ./networking.nix
    ./programs.nix
    ./qemu-guest.nix
    ./gui
  ];
}
