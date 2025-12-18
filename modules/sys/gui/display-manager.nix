{
  config,
  lib,
  pkgs,
  paths,
  ...
}:
{
  config = lib.mkIf config.j.gui.enable (
    let
      astronaut = (
        pkgs.sddm-astronaut.override {
          themeConfig = {
            background = "${paths.store.wallpapers}/default.jpg";
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
