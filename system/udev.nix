{
  host,
  lib,
  config,
  ...
}:
{
  options = {
    j.udev.debuggers = lib.mkEnableOption "udev rules for debuggers" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.udev.debuggers {
    services.udev.extraRules = ''
      ATTRS{product}=="*CMSIS-DAP*", MODE="664", GROUP="plugdev"
      ATTRS{product}=="*STM32*", MODE="664", GROUP="plugdev"
      ATTRS{product}=="*ST-LINK*", MODE="664", GROUP="plugdev"
      ATTRS{product}=="*CodeWarrior TAP*", MODE="664", GROUP="plugdev"
    '';
    users.users.${host.user}.extraGroups = [ "plugdev" ];
    users.groups.plugdev = { };
  };
}
