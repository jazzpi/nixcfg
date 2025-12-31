{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.j.gui.niri.enable {
    # Requirements
    j.gui = {
      uwsm.enable = true;
      kitty.enable = true;
      ashell.enable = true;
      wallpaper.enable = true;
      hypr = {
        lock.enable = true;
        idle.enable = true;
      };
    };
    programs.rofi.enable = true;
    home.packages = with pkgs; [
      wl-clipboard
      wl-clip-persist
      wlr-which-key
    ];

    programs.niri = {
      enable = true;
      package = pkgs.niri;
      settings = {
        spawn-at-startup = [
          {
            argv = [
              "${pkgs.uwsm}/bin/uwsm"
              "finalize"
            ];
          }
          { sh = "systemctl --user stop redshift"; }
        ];
        # TODO: binds
        binds = {
          "Mod+Return".action.spawn = "${getExe pkgs.kitty}";
          "Mod+d".action.spawn = [
            "${getExe pkgs.rofi}"
            "-show"
            "drun"
            "-show-icons"
            "-sort"
            "-sorting-method"
            "fzf"
          ];

          "Mod+Shift+q".action.close-window = { };

          "Mod+x".action.spawn-sh = "${getExe pkgs.wlr-which-key} --initial-keys x";

          # Screenshots
          "Mod+Shift+s".action.screenshot = { };
          "Print".action.screenshot = { };
          "Mod+Shift+p".action.spawn-sh = "${pkgs.wl-clipboard}/bin/wl-paste -n | ${getExe pkgs.swappy} -f -";

          # dunstctl
          "Mod+period".action.spawn = [
            "${pkgs.dunst}/bin/dunstctl"
            "close"
          ];
          "Mod+Shift+period".action.spawn = [
            "${pkgs.dunst}/bin/dunstctl"
            "close-all"
          ];
          "Mod+comma".action.spawn = [
            "${pkgs.dunst}/bin/dunstctl"
            "history-pop"
          ];

          # fn-keys
          "XF86AudioRaiseVolume".action.spawn = [
            "${pkgs.pulseaudio}/bin/pactl"
            "set-sink-volume"
            "@DEFAULT_SINK@"
            "+5%"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            "${pkgs.pulseaudio}/bin/pactl"
            "set-sink-volume"
            "@DEFAULT_SINK@"
            "-5%"
          ];
          "XF86AudioMute".action.spawn = [
            "${pkgs.pulseaudio}/bin/pactl"
            "set-sink-mute"
            "@DEFAULT_SINK@"
            "toggle"
          ];
          "XF86AudioPlay".action.spawn = [
            "${pkgs.playerctl}/bin/playerctl"
            "play-pause"
          ];
          "XF86AudioNext".action.spawn = [
            "${pkgs.playerctl}/bin/playerctl"
            "next"
          ];
          "XF86AudioPrev".action.spawn = [
            "${pkgs.playerctl}/bin/playerctl"
            "previous"
          ];
          "XF86MonBrightnessUp".action.spawn = [
            "${pkgs.brightnessctl}/bin/brightnessctl"
            "s"
            "+10%"
          ];
          "XF86MonBrightnessDown".action.spawn = [
            "${pkgs.brightnessctl}/bin/brightnessctl"
            "s"
            "10%-"
          ];
          # TODO: tab (overview?)
          # TODO: Qalculate

          # TODO: Do we want focus-column-or-monitor-left / focus-column-left-or-last ?
          "Mod+h".action.focus-column-left = { };
          "Mod+l".action.focus-column-right = { };
          # TODO: move-column-left-or-to-monitor-left ?
          "Mod+Shift+h".action.move-column-left = { };
          "Mod+Shift+l".action.move-column-right = { };
          # TODO: focus-window-or-monitor-up / focus-window-up-or-bottom ?
          "Mod+j".action.focus-window-down = { };
          "Mod+k".action.focus-window-up = { };
          # TODO: move-window-up-or-to-workspace-up ?
          "Mod+Shift+j".action.move-window-down = { };
          "Mod+Shift+k".action.move-window-up = { };
          "Mod+bracketleft".action.consume-or-expel-window-left = { };
          "Mod+bracketright".action.consume-or-expel-window-right = { };

          "Mod+r".action.switch-preset-column-width = { };
          "Mod+Shift+r".action.switch-preset-column-width-back = { };
          "Mod+f".action.maximize-column = { };
          "Mod+Shift+f".action.fullscreen-window = { };
          "Mod+w".action.toggle-column-tabbed-display = { };
          "Mod+Shift+Space".action.toggle-window-floating = { };
          "Mod+Space".action.switch-focus-between-floating-and-tiling = { };
        };
        # TODO: Named workspaces (IM, Spotify?)
        input = {
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
          keyboard = {
            numlock = true;
            xkb = {
              layout = "us";
              variant = "altgr-intl";
            };
          };
        };
        prefer-no-csd = true;
      };
    };

    xdg.configFile."wlr-which-key/config.yaml".text = ''
      menu:
        - key: "x"
          desc: "System"
          submenu:
            - key: "S"
              desc: "Shutdown"
              cmd: "systemctl poweroff"
            - key: "R"
              desc: "Reboot"
              cmd: "systemctl reboot"
            - key: "e" 
              desc: "Logout"
              cmd: "uwsm stop"
            - key: "l"
              desc: "Lock screen"
              cmd: "loginctl lock-session"
            - key: "s"
              desc: "Suspend"
              cmd: "systemctl suspend"
    '';

    # The niri module sets this to true. The hyprland module sets it to false,
    # since we set wayland.windowManager.hyprland.portalPackage to null.
    xdg.portal.enable = mkForce true;
    # TODO: XDG Autostart
    # TODO: additional packages (cf. hyprland config)
    # TODO: kanshi
  };
}
