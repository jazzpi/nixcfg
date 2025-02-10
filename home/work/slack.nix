{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.work.slack = {
    enable = lib.mkEnableOption "Slack" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.work.slack.enable {
    home.packages = with pkgs; [
      slack
    ];
  };
}
