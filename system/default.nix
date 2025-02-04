{ lib, ... }:
{
  imports = [
    ./common.nix
    ./programs.nix
    ./qemu-guest.nix
    ./gui
  ];
}
