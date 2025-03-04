{
  lib,
  config,
  ...
}:
{
  options.j.gui.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird" // {
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
  };
}
