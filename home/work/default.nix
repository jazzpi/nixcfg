{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.j.work.enable {
    j.gui.im.slack.enable = true;
    j.drive-sync = {
      enable = true;
      # Paths are set in private config
    };
  };
}
