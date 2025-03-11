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
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };
}
