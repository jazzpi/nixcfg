{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.j.work.enable {
    j.gui.im.slack.enable = true;
  };
}
