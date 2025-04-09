{
  pkgs,
  lib,
  config,
  rootPath,
  ...
}:
{
  options.j.gui.i3 = {
    workspaceAssignments = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };
    screens = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf config.j.gui.i3.enable {
    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
      config =
        let
          mod = "Mod4";
          modeResize = "resize";
          modeSystem = "System: [S]hutdown, [R]estart, [e]xit, [l]ock, [s]uspend";
        in
        {
          assigns = {
            "number 1" = [ { class = "^Firefox$"; } ];
            "number 2" = [ { class = "^Code$"; } ];
            "number 4" = [ { class = "^[Tt]hunderbird(-esr)?$"; } ];
            "number 5" = [ { class = "^[Ss]potify$"; } ];
            "i" = [
              { class = "^TelegramDesktop$"; }
              { class = "^Signal$"; }
              { class = "^Slack$"; }
            ];
          };
          floating = {
            criteria = [
              { window_type = "notification"; }
              { class = "^[Gg]nome-screenshot$"; }
              { title = "- Wine desktop$"; }
              { class = "^qalculate-qt$"; }
              {
                class = "Kicad";
                title = "^Assign Footprints$";
              }
            ];
            modifier = "${mod}";
          };
          defaultWorkspace = "workspace 2";
          workspaceOutputAssign = lib.mapAttrsToList (workspace: output: {
            inherit workspace output;
          }) config.j.gui.i3.workspaceAssignments;

          startup =
            [
              {
                command = "picom";
                notification = false;
              }
              {
                command = "dunst";
                notification = false;
              }
              # TODO: Move here as well
              {
                command = "~/.config/i3/scripts/startup.sh";
                notification = false;
              }
              {
                command = "~/.config/i3/scripts/background.sh";
                notification = false;
              }
            ]
            ++ lib.optionals config.j.gui.im.telegram.autostart [
              {
                command = "telegram-desktop";
                notification = false;
              }
            ]
            ++ lib.optionals config.j.gui.im.signal.autostart [
              {
                command = "signal-desktop";
                notification = false;
              }
            ]
            ++ lib.optionals config.j.gui.im.slack.autostart [
              {
                command = "slack";
                notification = false;
              }
            ];

          bars = [ ];

          colors = {
            background = "#ffffff";
            focused = {
              border = "#4c7899";
              background = "#285577";
              text = "#ffffff";
              indicator = "#2e9ef4";
              childBorder = "#285577";
            };
            focusedInactive = {
              border = "#333333";
              background = "#5f676a";
              text = "#ffffff";
              indicator = "#484e50";
              childBorder = "#5f676a";
            };
            unfocused = {
              border = "#333333";
              background = "#222222";
              text = "#888888";
              indicator = "#292d2e";
              childBorder = "#222222";
            };
            urgent = {
              border = "#2f343a";
              background = "#900000";
              text = "#ffffff";
              indicator = "#900000";
              childBorder = "#900000";
            };
            placeholder = {
              border = "#000000";
              background = "#0c0c0c";
              text = "#ffffff";
              indicator = "#000000";
              childBorder = "#0c0c0c";
            };
          };
          fonts = {
            names = [
              "DejaVu Sans Mono"
              "FontAwesome"
            ];
          };

          keybindings = lib.mkMerge [
            {
              # Misc
              "${mod}+Shift+q" = "kill";
              "${mod}+o" = "move container to output right";

              # Start applications
              "${mod}+Return" = "exec i3-sensible-terminal";
              "${mod}+Shift+d" = "exec --no-startup-id i3-dmenu-desktop";
              "${mod}+Mod1+d" = "exec --no-startup-id dmenu_run";
              "${mod}+d" = "exec --no-startup-id rofi -show drun -show-icons -sort -sorting-method fzf";

              # Notifications
              "${mod}+period" = "exec --no-startup-id dunstctl close";
              "${mod}+Shift+period" = "exec --no-startup-id dunstctl close-all";
              "${mod}+comma" = "exec --no-startup-id dunstctl history-pop";

              # Screenshots
              "Print" =
                "exec --no-startup-id bash -c \"~/.config/i3/scripts/screenshot.sh >> /tmp/screenshot.log 2>&1\"";
              "${mod}+Shift+s" =
                "exec --no-startup-id bash -c \"~/.config/i3/scripts/screenshot.sh >> /tmp/screenshot.log 2>&1\"";
              "Control+Print" = "exec gnome-screenshot -ac";
              "Shift+Print" = "exec gnome-screenshot -i";

              # Layouts
              "${mod}+g" = "split h";
              "${mod}+v" = "split v";
              "${mod}+s" = "layout stacking";
              "${mod}+w" = "layout tabbed";
              "${mod}+e" = "layout toggle split";
              "${mod}+Shift+space" = "floating toggle";
              "${mod}+space" = "focus mode_toggle";
              "${mod}+p" = "sticky toggle";

              # Fullscreen
              "${mod}+f" = "fullscreen toggle";
              "${mod}+Shift+f" = "fullscreen toggle global";

              # Scratchpad
              "${mod}+n" = "move scratchpad";
              "${mod}+Control+n" = "scratchpad show";
              "${mod}+Shift+n" = "scratchpad show; floating toggle";

              # i3 et al. management
              "${mod}+Shift+c" = "reload";
              "${mod}+Shift+r" = "restart";
              "${mod}+Shift+e" = "exec ~/.config/eww/scripts/restart.sh";

              # Window management
              "${mod}+m" = "exec i3-input -F 'mark \"%s\"' -P 'Mark as: ' -l1";
              "${mod}+grave" = "exec ~/.config/i3/scripts/mark-goto.bash";
              "${mod}+Tab" = "exec rofi -show window -show-icons";

              # Pulse Audio controls
              "XF86AudioRaiseVolume" =
                "exec --no-startup-id pactl -- set-sink-volume @DEFAULT_SINK@ +5% && killall -s USR1 py3status";
              "XF86AudioLowerVolume" =
                "exec --no-startup-id pactl -- set-sink-volume @DEFAULT_SINK@ -5% && killall -s USR1 py3status";
              "XF86AudioMute" =
                "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && killall -s USR1 py3status";
              "XF86AudioMicMute" =
                "exec --no-startup-id pactl -- set-source-mute @DEFAULT_SOURCE@ toggle && killall -s USR1 py3status";

              # Sreen brightness controls
              "XF86MonBrightnessUp" = "exec ~/.config/eww/scripts/backlight.sh change up";
              "XF86MonBrightnessDown" = "exec ~/.config/eww/scripts/backlight.sh change down";

              # Modes
              "${mod}+r" = "mode \"${modeResize}\"";
              "${mod}+x" = "mode \"${modeSystem}\"";
            }
            # Workspaces
            (lib.concatMapAttrs
              (key: ws: {
                "${mod}+${key}" = "workspace ${ws}";
                "${mod}+Shift+${key}" = "move container to workspace ${ws}";
              })
              (
                (lib.genAttrs ((map builtins.toString (lib.lists.range 1 9)) ++ [ "i" ]) builtins.toString)
                // {
                  "0" = "10";
                }
              )
            )
            # Movement
            (lib.concatMapAttrs
              (key: dir: {
                "${mod}+${key}" = "focus ${dir}";
                "${mod}+Shift+${key}" = "move ${dir}";
                "${mod}+Control+${key}" = "move workspace to output ${dir}";
              })
              {
                h = "left";
                j = "down";
                k = "up";
                l = "right";
                Left = "left";
                Down = "down";
                Up = "up";
                Right = "right";
              }
            )
          ];
          modes = {
            ${modeResize} = (
              lib.mkMerge [
                {
                  Return = "mode default";
                  Escape = "mode default";
                  "${mod}+r" = "mode default";
                }
                (lib.concatMapAttrs
                  (key: change: {
                    "${key}" = "resize ${change} 10 px or 10 ppt";
                    "Shift+${key}" = "resize ${change} 1 px or 1 ppt";
                  })
                  {
                    h = "shrink width";
                    j = "grow height";
                    k = "shrink height";
                    l = "grow width";
                    Left = "shrink width";
                    Down = "grow height";
                    Up = "shrink height";
                    Right = "grow width";
                  }
                )
              ]
            );
            ${modeSystem} = {
              "Shift+s" = "exec systemctl poweroff";
              "Shift+r" = "exec systemctl reboot";
              "e" = "exec xfce4-session-logout --logout";
              "l" = "exec xfce4-screensaver-command --lock; mode default";
              "s" = "exec systemctl suspend; mode default";
              Return = "mode default";
              Escape = "mode default";
              "${mod}+x" = "mode default";
            };
          };
        };
    };

    xdg.configFile = {
      "i3/scripts".source = "${rootPath}/dotfiles-repo/i3/scripts";
      "picom.conf".source = "${rootPath}/dotfiles-repo/picom.conf";
    };
    xdg.dataFile."dotfiles_resources".source = "${rootPath}/dotfiles-repo/resources";

    xfconf.settings.xfce4-desktop = lib.mkMerge (
      map (screen: {
        "backdrop/screen0/monitor${screen}/workspace0/last-image" =
          "${rootPath}/dotfiles-repo/resources/lockscreen.jpg";
      }) config.j.gui.i3.screens
    );

    programs = {
      rofi.enable = true;
      feh.enable = true;
    };
    services = {
      dunst.enable = lib.mkDefault true;
      picom.enable = lib.mkDefault true;
    };

    home.packages = with pkgs; [
      arandr
      gnome-screenshot
      swappy
    ];
    home.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 40;
    };

    j.gui.eww.enable = true;
  };
}
