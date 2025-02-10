let
  users = import ../../config/users.nix;
in
{
  home = {
    username = users.default;
    homeDirectory = "/home/${users.default}";
    stateVersion = "24.11";
  };

  j.personal.enable = true;
  j.work.enable = true;
  j.gui.i3.enable = true;
  j.gui.firefox.defaultProfile = "work";

  # Weird graphical glitches in virt-manager
  services.picom.enable = false;
}
