{
  home.stateVersion = "24.11";

  j.personal.enable = true;
  j.work.enable = true;
  j.gui.i3.enable = true;
  j.gui.firefox.defaultProfile = "work";

  # Weird graphical glitches in virt-manager
  services.picom.enable = false;
}
