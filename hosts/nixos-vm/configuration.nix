# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  networking.hostName = "nixos-vm";

  system.stateVersion = "24.11";

  j.boot.loader = "grub";
  boot.loader.grub.device = "/dev/vda";
  j.virt.qemu-guest.enable = true;
  j.virt.docker.enable = true;
  j.gui.i3.enable = true;
  j.networking.wireguard = true;
}
