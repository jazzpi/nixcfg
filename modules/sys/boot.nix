{
  lib,
  config,
  pkgs,
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
    initrdBluetooth = lib.mkEnableOption "Enable Bluetooth in initrd" // {
      default = false;
      description = "Enable Bluetooth support in the initrd for LUKS unlock";
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
      # WIP: Attempt to get bluetooth working in stage 1 boot (for LUKS unlock)
      # References:
      # https://www.reddit.com/r/NixOS/comments/1loabf9/bluetooth_in_the_initramfs_for_luks_password/
      # https://discourse.nixos.org/t/bluetooth-keyboard-in-stage-1/19259/30
      # https://github.com/dracutdevs/dracut/pull/1139/files
      # https://gitlab.com/generic-internet-user/nixos-config/-/blob/5246387d4055e26665707e322aa5e3e6c7ec7227/machines/hateful/initrd_btkbd.nix
      # https://www.reddit.com/r/pop_os/comments/10guj5y/connect_bluetooth_keyboard_before_disk_decryption/
      # https://github.com/irreleph4nt/mkinitcpio-bluetooth
      boot.initrd.systemd = lib.mkIf config.j.boot.initrdBluetooth {
        enable = true;
        packages = with pkgs; [ bluez ];
        initrdBin = with pkgs; [
          bluez
          dbus
          busybox
        ];
        dbus.enable = true;
        targets.initrd.wants = [ "bluetooth.service" ];
      };
      boot.kernelParams = [
        "rd.systemd.debug_shell"
      ];
    };
}
