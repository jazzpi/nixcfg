{
  lib,
  config,
  pkgs,
  paths,
  ...
}:
with lib;
let
  cfg = config.j.gui.niri;
  invertGradient =
    color:
    if color.gradient != null then
      recursiveUpdate color {
        gradient.angle = -color.gradient.angle;
      }
    else
      color;
in
{
  options.j.gui.niri = {
    theme = {
      active = mkOption {
        type = types.attrs;
        description = "Color for active windows.";
        default = {
          gradient = {
            from = "#dc3faaff";
            to = "#0fbabaff";
            angle = 45;
            in' = "oklch shorter hue";
          };
        };
      };
      inactive = mkOption {
        type = types.attrs;
        description = "Color for inactive windows.";
        default = {
          gradient = {
            from = "#745575ff";
            to = "#7c4958ff";
            angle = 45;
            in' = "oklch shorter hue";
          };
        };
      };
      urgent = mkOption {
        type = types.attrs;
        description = "Color for urgent windows.";
        default = {
          gradient = {
            from = "#ff0000ff";
            to = "#ff5500ff";
            angle = 45;
            in' = "oklch shorter hue";
          };
        };
      };
    };
  };
  config = mkIf cfg.enable {
    # Requirements
    j.gui = {
      uwsm.enable = true;
      kitty.enable = true;
      ashell.enable = true;
      wallpaper = {
        enable = true;
        extra-wallpapers = {
          wpaperd-overview = "${paths.store.wallpapers}/default.jpg";
        };
      };
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
      wdisplays
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
          { sh = "systemctl --user start wpaperd@wpaperd-overview.service"; }
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
          # TODO: Qalculate scratchpad
          # see https://github.com/YaLTeR/niri/discussions/329

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

          "Mod+u".action.focus-workspace-down = { };
          "Mod+i".action.focus-workspace-up = { };
          "Mod+Shift+u".action.move-column-to-workspace-down = {
            focus = false;
          };
          "Mod+Shift+i".action.move-column-to-workspace-up = {
            focus = false;
          };
          "Mod+Ctrl+u".action.move-workspace-down = { };
          "Mod+Ctrl+i".action.move-workspace-up = { };
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
            active = cfg.theme.active;
            inactive = cfg.theme.inactive;
          };
          tab-indicator = {
            width = 6;
            gap = 8;
            gaps-between-tabs = 4;
            corner-radius = 2.0;
            # Invert the gradients so the tab indicator pops more.
            active = invertGradient cfg.theme.active;
            inactive = invertGradient cfg.theme.inactive;
            urgent = invertGradient cfg.theme.urgent;
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
            # Disable border in general, but configure the colors so we don't
            # have to do that in window rules that enable the border.
            border = {
              enable = false;
              width = 4;
              active = cfg.theme.active;
              inactive = cfg.theme.inactive;
              urgent = cfg.theme.urgent;
            };
          }
          {
            matches = [ { is-urgent = true; } ];
            border.enable = true;
          }
          {
            matches = [ { is-floating = true; } ];
            border.enable = true;
            focus-ring.enable = false;
          }
          {
            matches = [ { app-id = "XEyes"; } ];
            open-floating = true;
            open-focused = false;
          }
          {
            matches = [ { app-id = "^qalculate"; } ];
            open-floating = true;
          }
        ];
        layer-rules = [
          {
            matches = [ { namespace = "^wpaperd-overview"; } ];
            place-within-backdrop = true;
          }
        ];
        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;
        xwayland-satellite = {
          enable = true;
          path = getExe pkgs.xwayland-satellite;
        };
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
