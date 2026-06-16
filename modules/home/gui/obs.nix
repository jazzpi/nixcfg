{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.gui.obs = {
    enable = lib.mkEnableOption "OBS Studio";
  };

  config = lib.mkIf config.j.gui.obs.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
        obs-vkcapture
        wlrobs
      ];
    };
  };
}
