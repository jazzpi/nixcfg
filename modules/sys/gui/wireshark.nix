{
  lib,
  config,
  pkgs,
  host,
  ...
}:
{
  options.j.gui.wireshark = {
    enable = lib.mkEnableOption "Wireshark" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.gui.wireshark.enable {
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    users.users.${host.user.name}.extraGroups = [ "wireshark" ];
  };
}
