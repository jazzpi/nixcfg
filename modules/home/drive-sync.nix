{
  lib,
  config,
  pkgs,
  templateFile,
  paths,
  ...
}:
{
  options.j.drive-sync = {
    enable = lib.mkEnableOption "GDrive sync" // {
      default = false;
    };
    sync-period = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "How often to sync with GDrive";
    };
    paths = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            localPath = lib.mkOption {
              type = lib.types.path;
              description = "Local path to sync to";
            };
            remotePath = lib.mkOption {
              type = lib.types.str;
              description = "Remote path to sync from";
            };
          };
        }
      );
    };
  };

  config = lib.mkIf config.j.drive-sync.enable (
    let
      filters-path = "gdrive-rclone/filters";
      sync-script = (
        templateFile {
          name = "drive-sync";
          template = "${paths.store.dots}/drive-sync/sync.mustache";
          data = {
            # Has to be stored in a writable path for rclone to update the md5
            filters_file = "${config.xdg.configHome}/${filters-path}";
          };
        }
      );
      sync-all-script = (
        pkgs.writeScript "sync-all" (
          ''
            #!${pkgs.bash}/bin/bash

            set -euo pipefail
          ''
          + lib.concatMapStrings (
            { localPath, remotePath }:
            ''
              ${sync-script} "${localPath}" "${remotePath}" "$@"
            ''
          ) config.j.drive-sync.paths
        )
      );
    in
    {
      # HM can do configuration for remotes/mounts as well. But unfortunately
      # rclone expects a mutable config file (to store/update OAuth tokens etc.)
      # so we have to do the configuration manually.
      programs.rclone.enable = true;
      home.packages = with pkgs; [
        libnotify
      ];
      xdg.configFile."${filters-path}".source = "${paths.store.dots}/drive-sync/filters";

      systemd.user = {
        services.drive-sync = {
          Unit = {
            Description = "Google Drive Sync";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${sync-all-script}";
          };
        };
        timers.drive-sync = {
          Unit = {
            Description = "Run GDrive sync periodically";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
          Timer = {
            OnBootSec = "1min";
            OnUnitActiveSec = "${config.j.drive-sync.sync-period}";
          };
        };
      };
    }
  );
}
