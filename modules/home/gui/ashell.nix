{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    j.gui.ashell = {
      enable = lib.mkEnableOption "AShell configuration" // {
        default = false;
      };
    };
  };

  config = lib.mkIf config.j.gui.ashell.enable {
    programs.ashell = {
      enable = true;
      package = inputs.ashell.packages.${pkgs.stdenv.hostPlatform.system}.default;
      settings = {
        enable_esc_key = true;
        modules = {
          left = [
            "Workspaces"
            "KeyboardSubmap"
          ];
          center = [
            "MediaPlayer"
          ];
          right = [
            "Privacy"
            "SystemInfo"
            "Tray"
            [
              "Settings"
              "Clock"
            ]
          ];
        };
        workspaces = {
          visibility_mode = "MonitorSpecific";
        };
        clock.format = "%F %H:%M:%S";
        system_info = {
          indicators = [
            "Cpu"
            "Memory"
            "Temperature"
          ];
          cpu = {
            warn_threshold = 60;
            alert_threshold = 80;
          };
          memory = {
            warn_threshold = 60;
            alert_threshold = 80;
          };
        };
        settings = {
          wifi_more_cmd = "nm-connection-editor";
          vpn_more_cmd = "nm-connection-editor";
          bluetooth_more_cmd = "overskride";
          audio_sinks_more_cmd = "pavucontrol -t 3";
          audio_sources_more_cmd = "pavucontrol -t 4";
        };
        appearance = {
          font_name = "Meslo LG S DZ";
          # scale_factor = 1.1;
        };
      };
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
    };
    systemd.user.services.ashell = {
      Service = {
        # See https://github.com/YaLTeR/niri/issues/1910 -- it's not fixed for
        # ashell, probably because it's based on the PopOS! fork instead of the
        # iced-rs/iced version.
        ExecStart = lib.mkForce "${lib.getExe pkgs.uwsm} app -- ${lib.getExe config.programs.ashell.package}";
        Environment = lib.optionals (config.j.gui.nvidia.enable) [ "WGPU_BACKEND=gl" ];
      };
      # Make sure ashell starts before autostart apps so that a tray is available.
      Unit.Before = "xdg-desktop-autostart.target";
    };
    # Bluetooth management
    home.packages = [ pkgs.overskride ];
  };
}
