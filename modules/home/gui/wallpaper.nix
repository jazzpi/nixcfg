{
  lib,
  config,
  inputs,
  host,
  paths,
  templateFile,
  ...
}:
with lib;
let
  wpaperd = config.j.gui.wallpaper.wpaperd;
in
{
  options = {
    j.gui.wallpaper = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable (Wayland) wallpaper";
      };
      wpaperd = mkOption {
        type = types.package;
        description = "wpaperd package";
        default = inputs.wpaperd.packages.${host.arch}.wpaperd;
      };
      extra-wallpapers = mkOption {
        type = types.attrsOf types.str;
        default = [ ];
        description = "Additional wallpapers to show on other layers. Key is the namespace, value is the path to the wallpaper image.";
      };
    };
  };

  config = mkIf config.j.gui.wallpaper.enable {
    home.packages = [ wpaperd ];
    systemd.user.services = {
      wpaperd = {
        Unit = {
          Description = "Wallpaper daemon for Wayland";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${wpaperd}/bin/wpaperd -v";
        };
      };
      "wpaperd@" = {
        Unit = {
          Description = "Wallpaper daemon instance for namespace %I";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${wpaperd}/bin/wpaperd -v -c \${XDG_CONFIG_HOME}/wpaperd/%i.toml";
        };
      };
      set-wallpaper = {
        Unit = {
          Description = "Set wallpaper path according to current date";
          After = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = (
            templateFile {
              name = "set-wallpaper";
              template = "${paths.store.dots}/hypr/scripts/set-wallpaper.mustache.sh";
              data = {
                wallpapersDir = paths.store.wallpapers;
                extraWallpapers = (
                  mapAttrsToList (name: value: ({
                    namespace = name;
                    path = value;
                  })) config.j.gui.wallpaper.extra-wallpapers
                );
              };
            }
          );
        };
      };
    };
  };
}
