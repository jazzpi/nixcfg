{
  lib,
  config,
  ...
}:
{
  options.j.work = {
    enable = lib.mkEnableOption "Work" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.work.enable {
    j.im.slack.enable = true;
  };
}
