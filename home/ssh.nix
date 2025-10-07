{ lib, config, ... }:
{
  options.j.ssh = {
    enable = lib.mkEnableOption "SSH configuration" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        default = {
          hostname = "*";
          setEnv = lib.optionalAttrs config.j.gui.kitty.enable {
            TERM = "xterm-256color";
          };
        };
      };
    };
  };
}
