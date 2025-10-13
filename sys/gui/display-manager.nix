{
  config,
  lib,
  pkgs,
  mkWallpaperPath,
  ...
}:
{
  config = lib.mkIf config.j.gui.enable (
    let
      astronaut = (
        pkgs.sddm-astronaut.override {
          themeConfig = {
            background = "${mkWallpaperPath { month = 0; }}";
          };
          embeddedTheme = "black_hole";
        }
      );
    in
    {
      services.displayManager.sddm = {
        enable = true;
        theme = "sddm-astronaut-theme";
        extraPackages = [
          astronaut
        ];
      };
      environment.systemPackages = [
        astronaut
      ];
    }
  );
}
