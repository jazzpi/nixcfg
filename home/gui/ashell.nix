{ lib, config, ... }:
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
        appearance = {
          font_name = "Meslo LG S DZ";
          scale_factor = 1.1;
        };
      };
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
    };
    # Make sure ashell starts before autostart apps so that a tray is available.
    systemd.user.services.ashell.Unit.Before = "xdg-desktop-autostart.target";
  };
}
