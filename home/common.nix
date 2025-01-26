{ lib, config, ... }:
{
  options.jh = {
    common.enable = lib.mkEnableOption "common programs" // {
      default = true;
    };
  };

  config = lib.mkIf config.jh.common.enable {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    programs.bash.enable = true;
    # TODO: Config
  };
}
