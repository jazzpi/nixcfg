{ pkgs, pkgs-stable, ... }:
{
  home.stateVersion = "24.11";

  j.personal.enable = true;
  j.gui.i3 = {
    enable = true;
    screens = [
      "eDP-1"
    ];
  };
  j.gui.gimp.enable = true;

  home.packages = (
    with pkgs;
    [
      stm32cubemx
      kicad
      # ])
      # ++ (with pkgs-stable; [
    ]
  );

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            scale = 1.2;
          }
        ];
      }
    ];
  };
}
