{
  pkgs,
  lib,
  config,
  rootPath,
  ...
}:
{
  options.j.gui.kitty = {
    enable = lib.mkEnableOption "Kitty terminal emulator" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.gui.kitty.enable {
    programs.kitty.enable = true;
    xdg.configFile."kitty".source = "${rootPath}/dotfiles-repo/kitty";
    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
