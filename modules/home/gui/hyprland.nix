{
  lib,
  config,
  pkgs,
  templateFile,
  paths,
  inputs,
  ...
}:
{
  options = {
    j.gui.hypr = {
      land = {
        theme = {
          active = lib.mkOption {
            type = lib.types.str;
            default = "rgb(89023e)";
            description = "Color of active windows";
          };
          inactive = lib.mkOption {
            type = lib.types.str;
            default = "rgb(444444)";
            description = "Color of inactive windows";
          };
          unlockedGroupActive = lib.mkOption {
            type = lib.types.str;
            default = "rgb(cc7178)";
            description = "Color of unlocked group active windows";
          };
        };
        mainMod = lib.mkOption {
          type = lib.types.str;
          default = "SUPER";
          description = "Main modifier key for Hyprland";
        };
      };
      wallpaper-service.enable =
        lib.mkEnableOption "Enable wallpaper setting service for hyprpaper/hyprlock"
        // {
          default = false;
        };
    };
  };
  config =
    let
      hypr = config.j.gui.hypr;
      cfg = hypr.land;
      submapGroups = "Groups";
      submapSystem = "System";
    in
    lib.mkMerge [
      (lib.mkIf hypr.land.enable {
        # Requirements
        j.gui.uwsm.enable = true;
        j.gui.kitty.enable = true;
        j.gui.ashell.enable = true;
        programs.rofi.enable = true;
        home.packages = with pkgs; [
          hyprshot
          hyprprop
          wl-clipboard
          wl-clip-persist
        ];
        j.gui.hypr = {
          lock.enable = true;
          idle.enable = true;
        };
        services = {
          hyprpolkitagent.enable = true;
          # TODO: Automatically set temperature?
          # TODO: Replace with sunsetr?
          hyprsunset.enable = true;
        };

        xdg.autostart.enable = true;

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false; # We use UWSM instead

          # Use Hyprland/XPDH packages from NixOS module
          package = null;
          portalPackage = null;

          plugins =
            let
            in
            [
              inputs.hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3
            ];

          extraConfig =
            # submaps aren't possible with the settings.bind syntax
            ''
              submap = ${submapGroups}
              bind = , h, hy3:focustab, l
              bind = , h, submap, reset
              bind = , l, hy3:focustab, r
              bind = , l, submap, reset
              bind = SHIFT, l, hy3:locktab, toggle
              bind = SHIFT, l, submap, reset
              bind = , escape, submap, reset
              submap = reset

              submap = ${submapSystem}
              bind = SHIFT, s, exec, systemctl poweroff
              bind = SHIFT, r, exec, systemctl reboot
              bind = , e, exit,
              bind = , l, exec, loginctl lock-session
              bind = , l, submap, reset
              bind = , s, exec, systemctl suspend
              bind = , s, submap, reset
              bind = , escape, submap, reset
              submap = reset

              # Mumble push-to-talk
              bind = ${cfg.mainMod}, backslash, exec, mumble rpc stoptalking; mumble rpc starttalking
              bindr = ${cfg.mainMod}, backslash, exec, mumble rpc stoptalking

              plugin {
                hy3 {
                  tab_first_window = false
                  tabs {
                    render_text = true
                    text_font = "Meslo LG S DZ, monospace"
                    text_height = 10
                    col.active = ${cfg.theme.unlockedGroupActive}
                    col.active.border = ${cfg.theme.unlockedGroupActive}
                    col.active.text = rgb(ffffff)
                    col.active_alt_monitor = ${cfg.theme.unlockedGroupActive}
                    col.active_alt_monitor.border = ${cfg.theme.unlockedGroupActive}
                    col.active_alt_monitor.text = rgb(ffffff)
                    col.locked = ${cfg.theme.active}
                    col.locked.border = ${cfg.theme.active}
                    col.locked.text = rgb(ffffff)
                    col.inactive = ${cfg.theme.inactive}
                    col.inactive.border = ${cfg.theme.inactive}
                    col.inactive.text = rgb(bbbbbb)
                  }
                }
              }
            '';
          settings = {
            monitor = lib.mkDefault ",preferred,auto,auto";

            exec-once = [
              # If these are enabled (e.g. because we have i3 enabled) systemd will constantly try to restart them
              "systemctl --user stop redshift"
              "wl-clip-persist --clipboard regular"
            ];

            windowrule = [
              "match:initial_class firefox, workspace 1 silent"
              # IM workspace
              "match:initial_class ^(signal|org.telegram.desktop|Slack|discord)$, workspace name:i silent"
              # TODO: This doesn't work (workspace rules are evaluated on startup only)
              # "match:initial_class ^firefox$,title:.*(Microsoft Teams|WhatsApp).*, workspace name:i silent"
              "match:initial_class ^thunderbird$, workspace 4 silent"
              "match:initial_class ^spotify$, workspace 5 silent"
              "match:initial_class ^qalculate-gtk$, float on"
              "match:initial_class ^qalculate-gtk$, workspace special:calc"
              "match:initial_class ^com.nextcloud.desktopclient.nextcloud$, float on"
              "match:initial_class ^org.freecad.FreeCAD$, workspace 6 silent"
            ];

            input = {
              kb_layout = "us";
              kb_variant = "altgr-intl";
              numlock_by_default = "true";

              follow_mouse = 1;

              touchpad.natural_scroll = "yes";

              sensitivity = "0"; # -1.0 - 1.0, 0 means no modification.
            };
            gesture = [
              "3, horizontal, workspace"
            ];

            misc = {
              enable_anr_dialog = false;
              disable_hyprland_logo = true;
            };

            # Theming
            general = {
              gaps_in = 5;
              gaps_out = 10;
              border_size = 2;
              "col.active_border" = cfg.theme.active;
              "col.inactive_border" = cfg.theme.inactive;

              layout = "hy3";

              allow_tearing = false;
            };
            decoration = {
              rounding = 5;
              blur.enabled = false;
            };
            animations = {
              enabled = "yes";
              animation = [
                "windows, 1, 2, default"
                "windowsOut, 1, 2, default, popin 80%"
                "border, 1, 10, default"
                "borderangle, 1, 8, default"
                "fade, 1, 5, default"
                "workspaces, 1, 3, default"
                "specialWorkspace, 1, 3, default, fade"
              ];
            };

            bind = [
              "${cfg.mainMod}, return, exec, uwsm app -- kitty"
              "${cfg.mainMod}, d, exec, rofi -show drun -show-icons -sort -sorting-method fzf -run-command 'uwsm app -- {cmd}'"

              "${cfg.mainMod} SHIFT, q, killactive, "

              # Layout control
              "${cfg.mainMod} SHIFT, space, togglefloating"
              "${cfg.mainMod}, p, pin"
              "${cfg.mainMod}, a, hy3:changefocus, raise"

              # Groups
              "${cfg.mainMod}, w, hy3:changegroup, toggletab"
              "${cfg.mainMod}, g, submap, ${submapGroups}"

              # System control
              "${cfg.mainMod}, x, submap, ${submapSystem}"

              # Screenshots
              ", Print, exec, uwsm app -- hyprshot --raw -m region | swappy -f -"
              "${cfg.mainMod} SHIFT, s, exec, uwsm app -- hyprshot --raw -m region | swappy -f -"

              "${cfg.mainMod}, period, exec, dunstctl close"
              "${cfg.mainMod} SHIFT, period, exec, dunstctl close-all"
              "${cfg.mainMod}, comma, exec, dunstctl history-pop"

              # fn-keys
              ", XF86AudioRaiseVolume, exec, pactl -- set-sink-volume @DEFAULT_SINK@ +5%"
              ", XF86AudioLowerVolume, exec, pactl -- set-sink-volume @DEFAULT_SINK@ -5%"
              ", XF86AudioMute, exec, pactl -- set-sink-mute @DEFAULT_SINK@ toggle"
              ", XF86AudioPlay, exec, playerctl play-pause"
              ", XF86AudioNext, exec, playerctl next"
              ", XF86AudioPrev, exec, playerctl previous"
              ", XF86MonBrightnessUp, exec, brightnessctl s +10%"
              ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"

              # Misc
              "${cfg.mainMod}, tab, exec, rofi -show window -show-icons -sort -sorting-method fzf"
              "${cfg.mainMod}, c, exec, pgrep qalculate-gtk && hyprctl dispatch togglespecialworkspace calc || uwsm app -- qalculate-gtk"
            ]
            # Workspace bindings
            ++ (lib.mapAttrsToList (bind: action: "${bind}, ${action}") (
              lib.concatMapAttrs
                (key: ws: {
                  "${cfg.mainMod}, ${key}" = "workspace, ${ws}";
                  "${cfg.mainMod} SHIFT, ${key}" = "hy3:movetoworkspace, ${ws}";
                })
                (
                  lib.genAttrs (map builtins.toString (lib.lists.range 1 9)) builtins.toString
                  // {
                    "0" = "10";
                    "i" = "name:i";
                  }
                )
            ))
            # Movement
            ++ (lib.mapAttrsToList (bind: action: "${bind}, ${action}") (
              lib.concatMapAttrs
                (key: dir: {
                  "${cfg.mainMod}, ${key}" = "hy3:movefocus, ${dir}";
                  "${cfg.mainMod} SHIFT, ${key}" = "hy3:movewindow, ${dir}";
                  "${cfg.mainMod} CTRL, ${key}" = "movecurrentworkspacetomonitor, ${dir}";
                })
                {
                  "h" = "l";
                  "j" = "d";
                  "k" = "u";
                  "l" = "r";
                  "left" = "l";
                  "down" = "d";
                  "up" = "u";
                  "right" = "r";
                }
            ));
            bindm = [
              # Move/resize windows with mainMod + LMB/RMB and dragging
              "${cfg.mainMod}, mouse:272, movewindow"
              "${cfg.mainMod}, mouse:273, resizewindow"
            ];
          };
        };
      })
      (lib.mkIf hypr.idle.enable {
        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pgrep hyprlock || hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = "hyprctl dispatch dpms on";
            };

            listener = [
              # Turn off screen after 5min
              {
                timeout = 300;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
              # Lock screen after 5:30min
              {
                timeout = 330;
                on-timeout = "loginctl lock-session";
              }
            ];
          };
        };
      })
      (lib.mkIf hypr.lock.enable {
        j.gui.wallpaper.enable = true;
        programs.hyprlock = {
          enable = true;
          settings = {
            background = {
              monitor = "";
              path = "$XDG_STATE_HOME/lockscreen.jpg";
              z-index = -2;
            };
            input-field = {
              monitor = "";
              hide_input = true;
              size = "200, 200";
              outline_thickness = 20;
              placeholder_text = "";
              capslock_color = "#FF0000";
            };
            shape = [
              # Make sure we can read the text on bright wallpapers
              {
                monitor = "";
                color = "rgba(0, 0, 0, 0.5)";
                z-index = -1;
                blur_passes = 3;
                size = "600, 100%";
                position = "0, 0";
                halign = "center";
                valign = "center";
              }
            ];
            label = [
              {
                monitor = "";
                position = "0, 200";
                font_size = 50;
                text = "$TIME";
                halign = "center";
                valign = "center";
                text_align = "center";
              }
              {
                monitor = "";
                position = "0, 300";
                font_size = 50;
                text = "cmd[update:1000] [ $ATTEMPTS -ne 0 ] && echo \"$ATTEMPTS ATTEMPTS\"";
                color = "rgba(255, 50, 0, 1)";
                halign = "center";
                valign = "center";
                text_align = "center";
              }
              {
                monitor = "";
                position = "0, 150";
                font_size = 20;
                text = "$FPRINTPROMPT";
                color = "rgba(254, 254, 254, 0.85)";
                halign = "center";
                valign = "center";
                text_align = "center";
              }
            ];
            auth.fingerprint = lib.mkIf (config.j.fprint.enable) {
              # Enables parallel fingerprint auth. Without this, fingerprint
              # auth is also possible, but only after pressing Enter (with an
              # empty password).
              enabled = true;
            };
          };
        };
      })
    ];
}
