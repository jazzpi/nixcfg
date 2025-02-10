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

  imports = [
    ./slack.nix
  ];

  config.j.work = lib.mkIf config.j.work.enable {
    slack.enable = true;
  };
}
