{
  lib,
  config,
  ...
}:
{
  options.j.gui.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird" // {
      default = config.j.gui.enable;
    };
    autostart = lib.mkEnableOption "Autostart Thunderbird" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.gui.thunderbird.enable {
    programs.thunderbird = {
      enable = true;
      profiles = {
        default = {
          isDefault = true;
          settings = {
            "mail.tabs.drawInTitlebar" = false;
          };
        };
      };
    };
    xdg.autostart.entries = lib.optionals config.j.gui.thunderbird.autostart [
      "${config.programs.thunderbird.package}/share/applications/thunderbird.desktop"
    ];
  };
}
