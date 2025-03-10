{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  system.stateVersion = "24.11";

  j.boot.loader = "grub";
  boot.loader.grub.device = "/dev/vda";
  j.virt.qemu-guest.enable = true;
  j.virt.docker.enable = true;
  j.gui.i3.enable = true;
  j.networking.wireguard = true;
}
