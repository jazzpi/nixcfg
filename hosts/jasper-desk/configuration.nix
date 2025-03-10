{ lib, ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  system.stateVersion = "24.11";

  j.boot.loader = "systemd-boot";
  j.virt.docker.enable = true;
  j.virt.docker.rootless = true;
  j.gui.i3.enable = true;
  j.networking.wireguard = true;

  j.gui.wireshark.enable = true;

  j.common.location = {
    latitude = 52.5;
    longitude = 13.1;
  };

  # Enable SSHD to install it
  services.sshd.enable = true;
  # Override the service's wantedBy to prevent it from starting on boot
  systemd.services.sshd.wantedBy = lib.mkForce [ ];
}
