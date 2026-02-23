{ config, lib, ... }:
{
  options = {
    j.yazi = {
      enable = lib.mkEnableOption "Yazi configuration" // {
        default = config.j.shell.enable;
      };
    };
  };

  config = lib.mkIf config.j.yazi.enable {
    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      extraPackages = [
        config.programs.zoxide.package
      ];
      shellWrapperName = "yy";
    };
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
