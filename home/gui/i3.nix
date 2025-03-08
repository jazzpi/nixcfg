{
  pkgs,
  pkgs-stable,
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
      # TODO: Move eww config (& needed packages) to separate module
      eww = {
        enable = true;
        configDir = "${rootPath}/dotfiles-repo/eww";
        # FIXME: Unstable eww duplicates the bars
        package = pkgs-stable.eww;
      };
    };
    services = {
      dunst.enable = lib.mkDefault true;
      picom.enable = lib.mkDefault true;
    };

    home.packages = with pkgs; [
      arandr
      gnome-screenshot
      swappy
      playerctl
    ];
  };
}
