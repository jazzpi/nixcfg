{ lib, ... }:
{
  imports = [
    ./common.nix
    ./networking.nix
    ./programs.nix
    ./audio.nix
    ./boot.nix
    ./udev.nix
    ./gui
    ./virt
  ];
}
