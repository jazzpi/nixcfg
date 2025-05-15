{
  lib,
  config,
  pkgs,
  rootPath,
  ...
}:
{
  options = {
    j.gui.hyprland = {
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
  };
  config =
    let
      cfg = config.j.gui.hyprland;
      submapGroups = "Groups";
      submapSystem = "System: [S]hutdown, [R]eboot, [e]xit, [l]ock, [s]uspend";
    in
    lib.mkIf cfg.enable {
      # Requirements
      j.gui.kitty.enable = true;
      j.gui.eww.enable = true;
      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
      };
      home.packages = with pkgs; [
        socat # Needed for eww scripts
        hyprpolkitagent
        hyprshot
      ];

      xdg.configFile."uwsm/env".text = ''
        export XCURSOR_SIZE=24
        export QT_QPA_PLATFORMTHEME=qt5ct
        export NIXOS_OZONE_WL=1
      '';

      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false; # We use UWSM instead
        extraConfig =
          # submaps aren't possible with the settings.bind syntax
          ''
            submap = ${submapGroups}
            bind = , h, changegroupactive, b
            bind = , h, submap, reset
            bind = , l, changegroupactive, f
            bind = , l, submap, reset
            bind = SHIFT, l, lockactivegroup, toggle
            bind = SHIFT, l, submap, reset
            bind = , escape, submap, reset
            submap = reset

            submap = ${submapSystem}
            bind=SHIFT, s, exec, systemctl poweroff
            bind=SHIFT, r, exec, systemctl reboot
            bind=, e, exit,
            bind=, l, exec, loginctl lock-session
            bind=, l, submap, reset
            bind=, s, exec, systemctl suspend
            bind=, s, submap, reset
            bind=, escape, submap, reset
            submap=reset
          '';
        settings = {
          monitor = lib.mkDefault ",preferred,auto,auto";

          exec-once = [
            "systemctl --user start hyprpolkitagent"
            "~/.config/eww/scripts/wm.sh launch"
            "dunst"
            "${rootPath}/dotfiles/hypr/scripts/startup.sh"
          ];

          windowrulev2 = [
            # IM workspace
            "workspace name:i,initialClass:^(signal|org.telegram.desktop)$"
            "group set,onworkspace:name:i"
            # TODO: This doesn't work (workspace rules are evaluated on startup only)
            "workspace name:i,initialClass:^firefox$,title:.*(Microsoft Teams|WhatsApp).*"
            "group set,initialClass:^firefox$,title:.*(Microsoft Teams|WhatsApp).*"
            "workspace 4,initialClass:^thunderbird$"
            "workspace 5,initialClass:^spotify$"
          ];

          input = {
            kb_layout = "us";
            kb_variant = "altgr-intl";
            numlock_by_default = "true";

            follow_mouse = 1;

            touchpad.natural_scroll = "yes";

            sensitivity = "0"; # -1.0 - 1.0, 0 means no modification.
          };
          gestures.workspace_swipe = "on";

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

            layout = "master";

            allow_tearing = false;
          };
          group = {
            "col.border_active" = cfg.theme.unlockedGroupActive;
            "col.border_inactive" = cfg.theme.inactive;
            "col.border_locked_active" = cfg.theme.active;
            "col.border_locked_inactive" = cfg.theme.inactive;
            groupbar = {
              enabled = true;
              scrolling = false;

              font_size = 10;
              font_family = "Meslo LG S DZ, monospace";
              height = 16;
              text_color = "rgb(ffffff)";
              gradients = true;
              "col.active" = cfg.theme.unlockedGroupActive;
              "col.inactive" = cfg.theme.inactive;
              "col.locked_active" = cfg.theme.active;
              "col.locked_inactive" = cfg.theme.inactive;
            };
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
            ];
          };

          bind =
            [
              "${cfg.mainMod}, return, exec, kitty"
              "${cfg.mainMod}, d, exec, rofi -show drun -show-icons -sort -sorting-method fzf"

              "${cfg.mainMod} SHIFT, q, killactive, "

              # Layout control
              "${cfg.mainMod} SHIFT, space, togglefloating"
              "${cfg.mainMod}, m, layoutmsg, focusmaster"
              "${cfg.mainMod} SHIFT, m, layoutmsg, swapwithmaster"
              "${cfg.mainMod}, e, layoutmsg, orientationnext"
              "${cfg.mainMod} SHIFT, e, layoutmsg, orientationprev"

              # Groups
              "${cfg.mainMod}, w, togglegroup"
              "${cfg.mainMod}, g, submap, ${submapGroups}"

              # System control
              "${cfg.mainMod}, x, submap, ${submapSystem}"

              # Screenshots
              ", Print, exec, hyprshot --raw -m region | swappy -f -"
              "${cfg.mainMod} SHIFT, s, exec, hyprshot --raw -m region | swappy -f -"

              "${cfg.mainMod}, period, exec, dunstctl close"
              "${cfg.mainMod} SHIFT, period, exec, dunstctl close-all"
              "${cfg.mainMod}, omma, exec, dunstctl history-pop"

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
            ]
            # Workspace bindings
            ++ (lib.mapAttrsToList (bind: action: "${bind}, ${action}") (
              lib.concatMapAttrs
                (key: ws: {
                  "${cfg.mainMod}, ${key}" = "workspace, ${ws}";
                  "${cfg.mainMod} SHIFT, ${key}" = "movetoworkspacesilent, ${ws}";
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
                  "${cfg.mainMod}, ${key}" = "movefocus, ${dir}";
                  "${cfg.mainMod} SHIFT, ${key}" = "movewindoworgroup, ${dir}";
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

      services = {
        hyprpaper = {
          enable = true;
          settings = {
            preload = "${rootPath}/dotfiles-repo/resources/wallpaper.jpg";
            wallpaper = ",${rootPath}/dotfiles-repo/resources/wallpaper.jpg";
          };
        };
        hypridle = {
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
      };
      programs = {
        hyprlock = {
          enable = true;
          settings = {
            background = {
              monitor = "";
              path = "${rootPath}/dotfiles-repo/resources/lockscreen.jpg";
            };
            input-field = {
              monitor = "";
              hide_input = true;
              size = "200, 200";
              outline_thickness = 20;
              placeholder_text = "";
              capslock_color = "#FF0000";
            };
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
            ];
          };
        };
      };
    };
}
