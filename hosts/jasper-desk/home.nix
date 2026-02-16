{
  inputs,
  pkgs,
  pkgs-stable,
  ...
}:
{
  home.stateVersion = "24.11";

  j.personal.enable = true;
  j.gui.firefox.defaultProfile = "personal";
  j.networking.can = true;
  j.gui.im.slack.autostart = false;

  j.gui.i3 = {
    enable = true;
    workspaceAssignments = {
      "1" = "DP-1";
      "2" = "DP-1";
      "i" = "DP-2";
      "4" = "DP-2";
      "5" = "DP-2";
    };
    screens = [
      "HDMI-0"
      "HDMI-1"
      "DP-0"
      "DP-1"
      "DP-2"
      "DP-3"
    ];
  };

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "desk-all";
        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "DP-1";
            position = "400,1080";
            mode = "3440x1440@100Hz";
          }
          {
            criteria = "DP-2";
            position = "1920,0";
          }
        ];
      }
      {
        profile.name = "desk-dp-only";
        profile.outputs = [
          {
            criteria = "DP-1";
            position = "400,1080";
          }
          {
            criteria = "DP-2";
            position = "1920,0";
          }
        ];
      }
      {
        profile.name = "tv-nomain";
        profile.outputs = [
          {
            criteria = "DENON, Ltd. DENON-AVAMP 0x01010101";
            position = "0,0";
            scale = 1.5;
          }
          {
            criteria = "DP-2";
            position = "1280,0";
            scale = 1.0;
          }
        ];
      }
    ];
  };

  j.gui.drawio.enable = true;
  j.sdr.enable = true;
  home.packages =
    (with pkgs; [
      stm32cubemx
      gimp3-with-plugins
      distrobox
      ckan
      bottles
    ])
    ++ (
      with pkgs-stable;
      [
        # cba to rebuild the 3D package every couple weeks
        kicad
        # These (or their dependencies) seem to be broken in unstable
        # see https://github.com/NixOS/nixpkgs/issues/475479
        minicom
        freecad
        obs-studio
      ]
      ++ [
        inputs.rstrf.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]
    );
}
