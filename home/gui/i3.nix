{
  pkgs,
  lib,
  config,
  rootPath,
  ...
}:
{
  options.j.gui.i3 = {
    enable = lib.mkEnableOption "i3 window manager" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.gui.i3.enable {
    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
    };

    xdg.configFile = {
      "i3".source = "${rootPath}/dotfiles-repo/i3";
      "picom.conf".source = "${rootPath}/dotfiles-repo/picom.conf";
    };
    xdg.dataFile."dotfiles_resources".source = "${rootPath}/dotfiles-repo/resources";

    programs = {
      rofi.enable = true;
      feh.enable = true;
      eww = {
        enable = true;
        configDir = "${rootPath}/dotfiles-repo/eww";
      };
    };
    services = {
      dunst.enable = lib.mkDefault true;
      picom.enable = lib.mkDefault true;
    };
  };
}
