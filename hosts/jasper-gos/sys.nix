{ lib, ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  system.stateVersion = "24.11";

  j.boot.loader = "systemd-boot";
  j.virt.docker.enable = true;
  j.virt.docker.rootless = false;
  j.virt.docker.addToDockerGroup = true;
  j.gui.i3.enable = true;
  j.networking.wireguard = true;
  j.networking.can = true;
  j.fprint.enable = true;

  j.gui.logic.enable = true;
  j.gui.wireshark.enable = true;

  # Enable SSHD to install it
  services.sshd.enable = true;
  # Override the service's wantedBy to prevent it from starting on boot
  systemd.services.sshd.wantedBy = lib.mkForce [ ];
}
