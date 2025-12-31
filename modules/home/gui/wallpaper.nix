{
  lib,
  config,
  pkgs,
  paths,
  templateFile,
  ...
}:
with lib;
{
  options = {
    j.gui.wallpaper.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable (Wayland) wallpaper";
    };
  };

  config = mkIf config.j.gui.wallpaper.enable {
    home.packages = with pkgs; [ wpaperd ];
    systemd.user.services = {
      wpaperd = {
        Unit = {
          Description = "Wallpaper daemon for Wayland";
          After = [ "set-wallpaper.service" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.wpaperd}/bin/wpaperd -d";
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
          # Give hyprpaper some time to open the IPC socket
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
          ExecStart = (
            templateFile {
              name = "set-wallpaper";
              template = "${paths.store.dots}/hypr/scripts/set-wallpaper.mustache.sh";
              data = {
                wallpapersDir = paths.store.wallpapers;
              };
            }
          );
        };
      };
    };
  };
}
