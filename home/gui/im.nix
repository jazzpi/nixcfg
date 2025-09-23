{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.gui.im =
    let
      mkMessenger = (
        name: configName: {
          ${configName} = {
            enable = lib.mkEnableOption "${name}" // {
              default = false;
            };
            autostart = lib.mkEnableOption "${name} autostart" // {
              default = config.j.gui.im.${configName}.enable;
            };
          };
        }
      );
    in
    (mkMessenger "Slack" "slack")
    // (mkMessenger "Signal" "signal")
    // (mkMessenger "Telegram" "telegram")
    // (mkMessenger "Discord" "discord");

  config =
    let
      cfg = config.j.gui.im;
    in
    {
      home.packages =
        with pkgs;
        lib.optionals cfg.slack.enable [
          slack
        ]
        ++ lib.optionals cfg.signal.enable [
          signal-desktop
        ]
        ++ lib.optionals cfg.telegram.enable [
          telegram-desktop
        ]
        ++ lib.optionals cfg.discord.enable [
          discord
        ];
      xdg.desktopEntries =
        lib.mkIf cfg.signal.enable {
          signal = {
            name = "Signal";
            exec = "${pkgs.signal-desktop}/bin/signal-desktop --password-store=gnome-libsecret";
          };
        }
        // lib.mkIf cfg.slack.enable {
          slack = {
            name = "Slack";
            # TODO: What if we run on X11?
            # TODO: Why is this needed? Nix starts it with --ozone-platform-hint=auto anyway,
            # which used to be enough. But now it seems to start with XWayland for some reason.
            exec = "${pkgs.slack}/bin/slack --ozone-platform=wayland";
          };
        };
    };
}
