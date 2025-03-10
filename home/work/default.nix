{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.j.work.enable {
    j.im.slack.enable = true;
  };
}
