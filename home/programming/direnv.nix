{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.jh.programming.direnv = {
    enable = lib.mkEnableOption "Direnv support (for dev shells)" // {
      default = true;
    };
  };

  config = lib.mkIf config.jh.programming.direnv.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
