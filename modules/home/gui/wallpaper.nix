{
  lib,
  config,
  inputs,
  pkgs,
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
        # FIXME: Remove override when the changes are upstreamed
        # I used the repo's flake previously, but that doesn't run on jasper-gos
        # (Failed to get EGL display during initialization).
        default = pkgs.wpaperd.overrideAttrs (oldAttrs: rec {
          version = "1.2.3";
          src = pkgs.fetchFromGitHub {
            owner = "jazzpi";
            repo = "wpaperd";
            tag = null;
            rev = "jasper-dev";
            hash = "sha256-2nYIb8aVFZss//aC5ao/WB/4hxMEjewfXOWR6+pZ4Lg=";
          };
          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            inherit src;
            hash = "sha256-Vz5x9V+q5OwRR/GdiM/kEEfENSQ+KyN3DKM35NHuzAk=";
          };
        });
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
