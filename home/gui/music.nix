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
  };

  config = lib.mkIf config.j.gui.spotify.enable {
    home.packages = with pkgs; [
      spotify
    ];
  };
}
