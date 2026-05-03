{
  lib,
  config,
  pkgs-stable,
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
      # FIXME: hash mismatch on unstable
      package = pkgs-stable.wireshark;
    };
    users.users.${host.user.name}.extraGroups = [ "wireshark" ];
  };
}
