{
  lib,
  config,
  ...
}:
{
  options.j.boot = {
    loader = lib.mkOption {
      type = lib.types.enum [
        "grub"
        "systemd-boot"
      ];
      description = "Bootloader type";
    };
  };

  config =
    lib.mkIf (config.j.boot.loader == "grub") {
      boot.loader.grub.enable = true;
      boot.loader.grub.useOSProber = true;
    }
    // lib.mkIf (config.j.boot.loader == "systemd-boot") {
      boot.loader.systemd-boot = {
        enable = true;
        # Sort all the NixOS generations to the end of the menu. The current
        # generation is the default, so this makes it easy to select both NixOS
        # and to select other entries.
        sortKey = "z_nixos";
      };
      boot.loader.efi.canTouchEfiVariables = true;
    };
}
