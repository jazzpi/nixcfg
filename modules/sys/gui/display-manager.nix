{
  config,
  lib,
  pkgs,
  paths,
  ...
}:
{
  options.j.gui.displayManager = {
    defaultSession = lib.mkOption {
      type = lib.types.str;
      description = "The default session to use.";
    };
  };
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
      services.displayManager = {
        enable = true;
        defaultSession = config.j.gui.displayManager.defaultSession;
        sddm = {
          enable = true;
          theme = "sddm-astronaut-theme";
          extraPackages = [
            astronaut
          ];
        };
      };
      environment.systemPackages = [
        astronaut
      ];
    }
  );
}
