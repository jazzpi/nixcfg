# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, host, ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  networking.hostName = host.hostname;

  system.stateVersion = "24.11";

  j.boot.loader = "systemd-boot";
  j.virt.docker.enable = true;
  j.virt.docker.rootless = true;
  j.gui.i3.enable = true;
  j.networking.wireguard = true;

  j.gui.wireshark.enable = true;

  # Enable SSHD to install it
  services.sshd.enable = true;
  # Override the service's wantedBy to prevent it from starting on boot
  systemd.services.sshd.wantedBy = lib.mkForce [ ];
}
