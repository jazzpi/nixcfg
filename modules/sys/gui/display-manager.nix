{
  config,
  lib,
  pkgs,
  rootPath,
  ...
}:
{
  config = lib.mkIf config.j.gui.enable (
    let
      astronaut = (
        pkgs.sddm-astronaut.override {
          themeConfig = {
            background = "${rootPath}/assets/wallpapers/default.jpg";
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
