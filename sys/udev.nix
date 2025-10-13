{
  host,
  lib,
  config,
  ...
}:
{
  options.j.udev = {
    debuggers = lib.mkEnableOption "udev rules for debuggers" // {
      default = true;
    };
    cannectivity = lib.mkEnableOption "udev rules for CANnectivity devices" // {
      default = config.j.networking.can;
    };
    plugdevGID = lib.mkOption {
      type = lib.types.int;
      default = 46; # ID of plugdev group on Ubuntu
      description = "The GID of the plugdev group";
    };
  };

  config =
    let
      cfg = config.j.udev;
    in
    lib.mkMerge [
      (lib.mkIf cfg.debuggers {
        services.udev.extraRules = ''
          ATTRS{product}=="*CMSIS-DAP*", MODE="664", GROUP="plugdev"
          ATTRS{product}=="*STM32*", MODE="664", GROUP="plugdev"
          ATTRS{product}=="*ST-LINK*", MODE="664", GROUP="plugdev"
          ATTRS{product}=="*STLINK*", MODE="664", GROUP="plugdev"
          ATTRS{product}=="DFU in * Mode", MODE="664", GROUP="plugdev"
          ATTRS{product}=="*CodeWarrior TAP*", MODE="664", GROUP="plugdev"
        '';
        users.users.${host.user.name}.extraGroups = [ "plugdev" ];
        users.groups.plugdev = {
          gid = cfg.plugdevGID;
        };
      })
      (lib.mkIf cfg.cannectivity {
        services.udev.extraRules = ''
          # Load gs_usb when a CANnectivity device is plugged in
          ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="ca01", RUN+="/sbin/modprobe -b gs_usb" MODE="660", GROUP="plugdev", TAG+="uaccess"
          # Bind CANnectivity devices to gs_usb driver (when gs_usb is loaded)
          SUBSYSTEM=="drivers", ENV{DEVPATH}=="/bus/usb/drivers/gs_usb", ATTR{new_id}="1209 ca01 ff"
          # Set permissions when a CANnectivity device in DFU mode is plugged in
          ATTR{idVendor}=="1209", ATTR{idProduct}=="ca02", MODE="660", GROUP="plugdev", TAG+="uaccess"
        '';
      })
    ];
}
