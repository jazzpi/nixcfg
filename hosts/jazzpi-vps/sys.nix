{ ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  j.boot.loader = "grub";
  boot.loader.grub.device = "/dev/vda";

  system.stateVersion = "24.11";

  # TODO: Podman

  services.sshd.enable = true;

  # For VSCode Server
  programs.nix-ld.enable = true;
}
