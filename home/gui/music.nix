{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.gui.spotify = {
    enable = lib.mkEnableOption "Spotify" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.gui.spotify.enable {
    home.packages = with pkgs; [
      spotify
    ];
  };
}
