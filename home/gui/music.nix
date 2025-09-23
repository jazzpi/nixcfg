{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.gui.spotify = {
    enable = lib.mkEnableOption "Spotify" // {
      default = config.j.gui.enable;
    };
    autostart = lib.mkEnableOption "Autostart Spotify" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.gui.spotify.enable {
    home.packages = with pkgs; [
      spotify
    ];
    xdg.autostart.entries = lib.optionals config.j.gui.spotify.autostart [
      "${pkgs.spotify}/share/applications/spotify.desktop"
    ];
  };
}
