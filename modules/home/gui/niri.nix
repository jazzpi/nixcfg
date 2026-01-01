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
        idle = {
          enable = true;
          compositors = {
            niri = {
              dpms-off = "niri msg action power-off-monitors";
              dpms-on = "niri msg action power-on-monitors";
            };
          };
        };
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
              "NIRI_SOCKET"
            ];
          }
          { sh = "systemctl --user stop redshift"; }
          { sh = "systemctl --user start hypridle@niri.service"; }
        ];
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

          "Mod+space".action.spawn-sh = "${getExe pkgs.wlr-which-key} niri";
          "Mod+x".action.spawn-sh = "${getExe pkgs.wlr-which-key} niri --initial-keys x";
          "Mod+w".action.spawn-sh = "${getExe pkgs.wlr-which-key} niri --initial-keys w";
          "Mod+m".action.spawn-sh = "${getExe pkgs.wlr-which-key} niri --initial-keys m";

          "Mod+Tab".action.spawn-sh =
            "${getExe pkgs.rofi} -show window -show-icons -sort -sorting-method fzf";
          "Mod+Shift+Tab".action.open-overview = { };

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
          # TODO: Qalculate

          "Mod+h".action.focus-column-left = { };
          "Mod+l".action.focus-column-right = { };
          "Mod+Shift+h".action.move-column-left = { };
          "Mod+Shift+l".action.move-column-right = { };
          "Mod+j".action.focus-window-down = { };
          "Mod+k".action.focus-window-up = { };
          "Mod+Shift+j".action.move-window-down = { };
          "Mod+Shift+k".action.move-window-up = { };
          "Mod+bracketleft".action.consume-or-expel-window-left = { };
          "Mod+bracketright".action.consume-or-expel-window-right = { };

          "Mod+r".action.switch-preset-column-width = { };
          "Mod+Shift+r".action.switch-preset-column-width-back = { };
          "Mod+Shift+Space".action.toggle-window-floating = { };

          "Mod+u".action.focus-workspace-up = { };
          "Mod+i".action.focus-workspace-down = { };
          "Mod+Shift+u".action.move-column-to-workspace-up = { };
          "Mod+Shift+i".action.move-column-to-workspace-down = { };
          "Mod+Ctrl+u".action.move-workspace-up = { };
          "Mod+Ctrl+i".action.move-workspace-down = { };
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
        layout = {
          empty-workspace-above-first = true;
          gaps = 8;
          struts = {
            left = 40;
            right = 40;
            top = 5;
            bottom = 5;
          };
          focus-ring = {
            enable = true;
            width = 4;
            active.gradient = {
              from = "#dc3faaff";
              to = "#0fbabaff";
              angle = 45;
              in' = "oklch shorter hue";
            };
            inactive.gradient = {
              from = "#745575ff";
              to = "#7c4958ff";
              angle = 45;
              in' = "oklch shorter hue";
            };
          };
        };
        window-rules = [
          {
            geometry-corner-radius = {
              bottom-left = 5.0;
              bottom-right = 5.0;
              top-left = 5.0;
              top-right = 5.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [ { is-urgent = true; } ];
            border = {
              enable = true;
              width = 4;
              urgent.gradient = {
                from = "#ff0000ff";
                to = "#ff5500ff";
                angle = 45;
                in' = "oklch shorter hue";
              };
            };
          }
        ];
      };
    };

    xdg.configFile."wlr-which-key/niri.yaml".text =
      let
        shell-cmd = (key: desc: cmd: { inherit key desc cmd; });
        niri-action = (
          key: desc: action: {
            inherit key desc;
            cmd = "niri msg action ${action}";
          }
        );
      in
      generators.toYAML { } {
        menu = [
          {
            key = "x";
            desc = "System";
            submenu = [
              (shell-cmd "S" "Shutdown" "systemctl poweroff")
              (shell-cmd "R" "Reboot" "systemctl reboot")
              (shell-cmd "e" "Logout" "uwsm stop")
              (shell-cmd "l" "Lock screen" "loginctl lock-session")
              (shell-cmd "s" "Suspend" "systemctl suspend")
            ];
          }
          {
            key = "w";
            desc = "Window/Column";
            submenu = [
              (niri-action "space" "Toggle floating" "toggle-window-floating")
              (niri-action "Alt+space" "Switch focus floating/tiling" "switch-focus-between-floating-and-tiling")
              (niri-action "f" "Maximize column" "maximize-column")
              (niri-action "F" "Fullscreen window" "fullscreen-window")
              (niri-action "w" "Tab column" "toggle-column-tabbed-display")
              (niri-action "r" "Increase column width" "switch-preset-column-width")
              (niri-action "R" "Decrease column width" "switch-preset-column-width-back")
            ];
          }
          {
            key = "m";
            desc = "Monitor";
            submenu = [
              (niri-action "h" "Focus left" "focus-monitor-left")
              (niri-action "l" "Focus right" "focus-monitor-right")
              (niri-action "j" "Focus down" "focus-monitor-down")
              (niri-action "k" "Focus up" "focus-monitor-up")
              (niri-action "H" "Move column left" "move-column-to-monitor-left")
              (niri-action "L" "Move column right" "move-column-to-monitor-right")
              (niri-action "J" "Move column down" "move-column-to-monitor-down")
              (niri-action "K" "Move column up" "move-column-to-monitor-up")
              (niri-action "Ctrl+h" "Move workspace left" "move-workspace-to-monitor-left")
              (niri-action "Ctrl+l" "Move workspace right" "move-workspace-to-monitor-right")
              (niri-action "Ctrl+j" "Move workspace down" "move-workspace-to-monitor-down")
              (niri-action "Ctrl+k" "Move workspace up" "move-workspace-to-monitor-up")
            ];
          }
        ];
      };

    # The niri module sets this to true. The hyprland module sets it to false,
    # since we set wayland.windowManager.hyprland.portalPackage to null.
    xdg.portal.enable = mkForce true;
    # TODO: XDG Autostart
    # TODO: additional packages (cf. hyprland config)
    # TODO: kanshi
  };
}
