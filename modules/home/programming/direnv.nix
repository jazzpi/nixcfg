{
  lib,
  config,
  ...
}:
{
  options.j.programming.direnv = {
    enable = lib.mkEnableOption "Direnv support (for dev shells)" // {
      default = config.j.programming.enable;
    };
  };

  config = lib.mkIf config.j.programming.direnv.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
