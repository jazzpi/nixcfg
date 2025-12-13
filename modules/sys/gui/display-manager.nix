{
  config,
  lib,
  pkgs,
  wallpaperPath,
  ...
}:
{
  config = lib.mkIf config.j.gui.enable (
    let
      astronaut = (
        pkgs.sddm-astronaut.override {
          themeConfig = {
            background = wallpaperPath;
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
