{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.j.gui.niri.enable {
    # Requirements
    j.gui = {
      kitty.enable = true;
      # ashell.enable = true; # TODO: Merge niri support into my branch
    };
    programs.rofi.enable = true;
    home.packages = with pkgs; [
      wl-clipboard
      wl-clip-persist
    ];
    programs.niri = {
      enable = true;
      package = pkgs.niri;
      settings = {
        # TODO: binds
        # TODO: Named workspaces (IM, Spotify?)
        input = {
          focus-follows-mouse.enable = true;
          keyboard = {
            numlock = true;
            xkb = {
              layout = "us";
              variant = "altgr-intl";
            };
          };
        };
      };
    };
    # TODO: XDG Autostart
    # TODO: additional packages (cf. hyprland config)
    # TODO: kanshi
  };
}
