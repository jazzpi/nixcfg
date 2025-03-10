{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.im = {
    slack.enable = lib.mkEnableOption "Slack" // {
      default = false;
    };
    signal.enable = lib.mkEnableOption "Signal" // {
      default = false;
    };
    telegram.enable = lib.mkEnableOption "Telegram" // {
      default = false;
    };
  };

  config = {
    home.packages =
      let
        cfg = config.j.im;
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
      ];
  };
}
