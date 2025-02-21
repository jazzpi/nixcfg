{ lib, ... }:
{
  imports = [
    ./common.nix
    ./networking.nix
    ./programs.nix
    ./audio.nix
    ./gui
    ./virt
  ];
}
