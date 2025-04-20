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
    windows = {
      enable = lib.mkEnableOption "Windows" // {
        default = false;
        description = "Enable Windows boot entry";
      };
      efiDeviceHandle = lib.mkOption {
        type = lib.types.str;
        description = "EFI device handle for Windows boot entry";
      };
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
        edk2-uefi-shell = {
          enable = true;
          sortKey = "0";
        };
        windows = lib.optionalAttrs config.j.boot.windows.enable {
          windows = {
            title = "Windows (${config.j.boot.windows.efiDeviceHandle})";
            efiDeviceHandle = config.j.boot.windows.efiDeviceHandle;
            sortKey = "1";
          };
        };
      };
      boot.loader.efi.canTouchEfiVariables = true;
    };
}
