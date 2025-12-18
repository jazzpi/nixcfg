{
  lib,
  config,
  paths,
  ...
}:
{
  options.j.gui.kitty = {
    enable = lib.mkEnableOption "Kitty terminal emulator" // {
      default = config.j.gui.enable;
    };
  };

  config = lib.mkIf config.j.gui.kitty.enable {
    programs.kitty.enable = true;
    xdg.configFile."kitty".source = "${paths.store.dots-repo}/kitty";
    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
