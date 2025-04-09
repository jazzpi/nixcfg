{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.gui.im = {
    slack = {
      enable = lib.mkEnableOption "Slack" // {
        default = false;
      };
      autostart = lib.mkEnableOption "Slack autostart" // {
        default = config.j.gui.im.slack.enable;
      };
    };
    signal = {
      enable = lib.mkEnableOption "Signal" // {
        default = false;
      };
      autostart = lib.mkEnableOption "Signal autostart" // {
        default = config.j.gui.im.signal.enable;
      };
    };
    telegram = {
      enable = lib.mkEnableOption "Telegram" // {
        default = false;
      };
      autostart = lib.mkEnableOption "Telegram autostart" // {
        default = config.j.gui.im.telegram.enable;
      };
    };
  };

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
      ];
  };
}
