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

  config = {
    home.packages =
      let
        cfg = config.j.gui.im;
      in
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
  };
}
