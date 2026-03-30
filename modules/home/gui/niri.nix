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
    if (match ".*angle=-.*" color) != null then
      replaceString "angle=-" "angle=" color
    else
      replaceString "angle=" "angle=-" color;
in
{
  options.j.gui.niri = {
    theme = {
      active = mkOption {
        type = types.str;
        description = "Color for active windows.";
        default = ''gradient from="#b94900" to="#6f249f" angle=45 in="oklch shorter hue"'';
      };
      inactive = mkOption {
        type = types.str;
        description = "Color for inactive windows.";
        default = ''color "#606060"'';
      };
      urgent = mkOption {
        type = types.str;
        description = "Color for urgent windows.";
        default = ''gradient from="#ff0000ff" to="#ff5500ff" angle=45 in="oklch shorter hue"'';
      };
    };
    overview-key = mkOption {
      type = types.str;
      description = "Keybinding to open the Niri overview (with which-key).";
      default = "Tab";
    };
    im-workspace = mkOption {
      type = types.str;
      description = "Name of the workspace to use for (instant) messaging apps.";
      default = "M";
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

    xdg.configFile."niri/config.kdl".text = ''
      spawn-sh-at-startup "${pkgs.uwsm}/bin/uwsm finalize NIRI_SOCKET";
      spawn-sh-at-startup "systemctl --user stop redshift";
      spawn-sh-at-startup "systemctl --user start wpaperd@wpaperd-overview.service"

      binds {
        "Mod+Return" { spawn "${getExe pkgs.kitty}"; }
        "Mod+d" { spawn-sh "${getExe pkgs.rofi} -show drun -show-icons -sort -sorting-method fzf"; }

        "Mod+Shift+q" { close-window; }

        "Mod+x" { spawn-sh "${getExe pkgs.wlr-which-key} niri --initial-keys x"; }

        "Mod+${cfg.overview-key}" {
          spawn-sh "niri msg action open-overview && ${getExe pkgs.wlr-which-key} niri --initial-keys ${cfg.overview-key}";
        }
        "Mod+Shift+Tab" { spawn-sh "${getExe pkgs.rofi} -show window -show-icons -sort -sorting-method fzf"; }

        // Screenshots
        "Mod+Shift+s" { screenshot; }
        "Print" { screenshot; }
        "Mod+Shift+v" { spawn-sh "${pkgs.wl-clipboard}/bin/wl-paste -n | ${getExe pkgs.swappy} -f -"; }

        // Notifications
        "Mod+period" { spawn-sh "${pkgs.dunst}/bin/dunstctl close"; }
        "Mod+Shift+period" { spawn-sh "${pkgs.dunst}/bin/dunstctl close-all"; }
        "Mod+comma" { spawn-sh "${pkgs.dunst}/bin/dunstctl history-pop"; }

        // fn-keys
        "XF86AudioRaiseVolume" {
          spawn-sh "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        }
        "XF86AudioLowerVolume" {
          spawn-sh "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        }
        "XF86AudioMute" {
          spawn-sh "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        }
        "XF86AudioPlay" {
          spawn-sh "${pkgs.playerctl}/bin/playerctl play-pause";
        }
        "XF86AudioNext" {
          spawn-sh "${pkgs.playerctl}/bin/playerctl next";
        }
        "XF86AudioPrev" {
          spawn-sh "${pkgs.playerctl}/bin/playerctl previous";
        }
        "XF86MonBrightnessUp" {
          spawn-sh "${pkgs.brightnessctl}/bin/brightnessctl s +10%";
        }
        "XF86MonBrightnessDown" {
          spawn-sh "${pkgs.brightnessctl}/bin/brightnessctl s 10%-";
        }

        // TODO: Qalculate scratchpad
        // see https://github.com/YaLTeR/niri/discussions/329

        "Mod+h" { focus-column-left; }
        "Mod+l" { focus-column-right; }
        "Mod+Shift+h" { move-column-left; }
        "Mod+Shift+l" { move-column-right; }
        "Mod+j" { focus-window-down; }
        "Mod+k" { focus-window-up; }
        "Mod+Shift+j" { move-window-down; }
        "Mod+Shift+k" { move-window-up; }
        "Mod+bracketleft" { consume-or-expel-window-left; }
        "Mod+bracketright" { consume-or-expel-window-right; }

        "Mod+r" { switch-preset-column-width; }
        "Mod+Shift+r" { switch-preset-column-width-back; }
        "Mod+1" { set-column-width "33.333%"; }
        "Mod+2" { set-column-width "50%"; }
        "Mod+3" { set-column-width "66.667%"; }
        "Mod+f" { maximize-column; }
        "Mod+Shift+f" { fullscreen-window; }
        "Mod+Shift+Space" { toggle-window-floating; }

        "Mod+u" { focus-workspace-down; }
        "Mod+i" { focus-workspace-up; }
        "Mod+Shift+u" { move-column-to-workspace-down focus=false; }
        "Mod+Shift+i" { move-column-to-workspace-up focus=false; }
        "Mod+Ctrl+u" { move-workspace-down; }
        "Mod+Ctrl+i" { move-workspace-up; }
        "Mod+m" { focus-workspace "${cfg.im-workspace}"; }
        "Mod+Shift+m" { move-column-to-workspace "${cfg.im-workspace}" focus=false; }

        "Mod+o" { focus-monitor-next; }
        "Mod+p" { focus-monitor-previous; }
        "Mod+Shift+o" { move-column-to-monitor-next; }
        "Mod+Shift+p" { move-column-to-monitor-previous; }
        "Mod+Ctrl+o" { move-workspace-to-monitor-next; }
        "Mod+Ctrl+p" { move-workspace-to-monitor-previous; }
      }

      input {
        focus-follows-mouse max-scroll-amount="0%"
        keyboard {
          numlock
          xkb {
            layout "us"
            variant "altgr-intl"
          }
        }
        touchpad {
          natural-scroll
          scroll-method "two-finger"
          tap
          dwt
          tap-button-map "left-right-middle"
        }
      }

      gestures {
        hot-corners { off; }
      }

      workspace "${cfg.im-workspace}"

      layout {
        empty-workspace-above-first
        gaps 8
        focus-ring {
          on
          width 4
          active-${cfg.theme.active}
          inactive-${cfg.theme.inactive}
        }
        tab-indicator {
          width 6
          gap 0
          gaps-between-tabs 4
          corner-radius 2.0
          active-color "#00dbab"
          inactive-color "#65638d"
          urgent-${invertGradient cfg.theme.urgent}
        }
      }

      window-rule {
        geometry-corner-radius 5
        clip-to-geometry true
        // Disable border in general, but configure the colors so we don't have
        // to do that in window rules that enable the border.
        border {
          off
          width 4
          active-${cfg.theme.active}
          inactive-${cfg.theme.inactive}
          urgent-${cfg.theme.urgent}
        }
      }

      window-rule {
        match is-urgent=true
        border { on; }
      }

      window-rule {
        match is-floating=true
        border { on; }
        focus-ring { off; }
      }

      window-rule {
        match at-startup=true
        open-focused false
      }

      window-rule {
        match app-id="XEyes"
        open-floating true
        open-focused false
      }

      window-rule {
        match app-id=r#"^qalculate"#
        open-floating true
      }

      window-rule {
        match app-id=r#"^(signal|org\.telegram\.desktop|Slack|discord|thunderbird)"#
        open-on-workspace "${cfg.im-workspace}"
      }

      window-rule {
        // Open file picker portal floating.
        // TODO: normal windows open floating too. Can we distinguish them?
        match app-id="org.gnome.Nautilus"
        open-floating true
      }

      layer-rule {
        match namespace=r#"^wpaperd-overview"#
        place-within-backdrop true
      }

      prefer-no-csd
      hotkey-overlay {
        skip-at-startup
      }
      xwayland-satellite {
        path "${getExe pkgs.xwayland-satellite}"
      }
    '';

    xdg.configFile."wlr-which-key/niri.yaml".text =
      let
        shell-cmd = (key: desc: cmd: { inherit key desc cmd; });
        niri-action = (
          key: desc: action: {
            inherit key desc;
            cmd = "niri msg action ${action}";
          }
        );
        niri-action-o = (
          key: desc: action: {
            inherit key desc;
            cmd = "niri msg action ${action}";
            keep_open = true;
          }
        );
        niri-action-r = (
          key: desc: action: {
            inherit key desc;
            cmd = ''
              niri msg action ${action}
              ${getExe pkgs.wlr-which-key} niri --initial-keys ${cfg.overview-key}
            '';
          }
        );
      in
      generators.toYAML { } {
        rows_per_column = 15;
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
          # Menu for managing layout / monitors in the Niri overview. The menu
          # stays open after executing an action, so we can e.g. move a column
          # across multiple monitors and workspaces without reopening the
          # overview every time.
          {
            key = cfg.overview-key;
            desc = "Navigation";
            submenu = [
              # Windows / columns
              (niri-action-o "h" "Focus left" "focus-column-left")
              (niri-action-o "j" "Focus down" "focus-window-down")
              (niri-action-o "k" "Focus up" "focus-window-up")
              (niri-action-o "l" "Focus right" "focus-column-right")
              (niri-action-o "H" "Move left" "move-column-left")
              (niri-action-o "J" "Move down" "move-window-down")
              (niri-action-o "K" "Move up" "move-window-up")
              (niri-action-o "L" "Move right" "move-column-right")
              (niri-action-o "bracketleft" "Consume/expel left" "consume-or-expel-window-left")
              (niri-action-o "bracketright" "Consume/expel right" "consume-or-expel-window-right")
              (niri-action-o "f" "Maximize" "maximize-column")
              (niri-action-o "F" "Fullscreen" "fullscreen-window")
              (niri-action-o "t" "Tab column" "toggle-column-tabbed-display")
              # Workspaces
              (niri-action-o "u" "WS: Focus down" "focus-workspace-down")
              (niri-action-o "i" "WS: Focus up" "focus-workspace-up")
              (niri-action-o "U" "Move to WS down" "move-column-to-workspace-down")
              (niri-action-o "I" "Move to WS up" "move-column-to-workspace-up")
              (niri-action-o "Ctrl+u" "WS: Move down" "move-workspace-down")
              (niri-action-o "Ctrl+i" "WS: Move up" "move-workspace-up")
              (niri-action-o "m" "WS: Focus IM" "focus-workspace ${cfg.im-workspace}")
              (niri-action-o "M" "Move to WS IM" "move-column-to-workspace ${cfg.im-workspace}")
              # Monitors
              # For these, keep_open doesn't really work because the overlay
              # will remain on the original monitor. So instead, we re-open the
              # overlay after executing the action.
              (niri-action-r "w" "M: Focus up" "focus-monitor-up")
              (niri-action-r "a" "M: Focus left" "focus-monitor-left")
              (niri-action-r "s" "M: Focus down" "focus-monitor-down")
              (niri-action-r "d" "M: Focus right" "focus-monitor-right")
              (niri-action-r "W" "M: Move up" "move-column-to-monitor-up")
              (niri-action-r "A" "M: Move left" "move-column-to-monitor-left")
              (niri-action-r "S" "M: Move down" "move-column-to-monitor-down")
              (niri-action-r "D" "M: Move right" "move-column-to-monitor-right")
              (niri-action-r "Ctrl+w" "M: Move WS up" "move-workspace-to-monitor-up")
              (niri-action-r "Ctrl+a" "M: Move WS left" "move-workspace-to-monitor-left")
              (niri-action-r "Ctrl+s" "M: Move WS down" "move-workspace-to-monitor-down")
              (niri-action-r "Ctrl+d" "M: Move WS right" "move-workspace-to-monitor-right")
              # Close niri overview without keep_open -> close overview &
              # which-key at the same time
              (niri-action cfg.overview-key "Close overview" "close-overview")
              (niri-action "Return" "Close overview" "close-overview")
              (niri-action "Escape" "Close overview" "close-overview")
            ];
          }
        ];
      };

    # We configure this in the NixOS module instead
    # xdg.portal.enable = mkForce true;
    # TODO: XDG Autostart
    # TODO: additional packages (cf. hyprland config)
    # TODO: kanshi
  };
}
