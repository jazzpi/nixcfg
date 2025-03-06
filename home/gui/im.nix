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
      with pkgs;
      with config.j.im;
      lib.optionals slack.enable [
        slack
      ]
      ++ lib.optionals signal.enable [
        signal-desktop
      ]
      ++ lib.optionals telegram.enable [
        telegram-desktop
      ];
  };
}
