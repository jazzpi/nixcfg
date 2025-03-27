{
  pkgs,
  pkgs-stable,
  lib,
  config,
  rootPath,
  ...
}:
{
  options.j.gui.eww = {
    enable = lib.mkEnableOption "EWW" // {
      default = false;
    };
    backlight = lib.mkEnableOption "EWW Backlight Widget" // {
      default = false;
    };
    battery = {
      enable = lib.mkEnableOption "EWW Battery Widget" // {
        default = false;
      };
      batteryName = lib.mkOption {
        type = lib.types.str;
        default = "BAT0";
        description = "The name of the battery to monitor";
      };
    };
    bluetooth = lib.mkEnableOption "EWW Bluetooth Widget" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.gui.eww.enable {
    programs.eww = {
      enable = true;
      enableBashIntegration = true;
      # FIXME: Unstable eww duplicates the bars
      package = pkgs-stable.eww;
    };
    xdg.configFile."eww/eww.yuck".source = "${rootPath}/dotfiles/eww/eww.yuck";
    xdg.configFile."eww/eww.scss".source = "${rootPath}/dotfiles/eww/eww.scss";
    xdg.configFile."eww/scripts".source = "${rootPath}/dotfiles/eww/scripts";
    xdg.configFile."eww/generated.yuck".text =
      ''
        (defwidget right-info [monitor]
          (box
            :class "right-info"
            :orientation "horizontal"
            :halign "end"
            :space-evenly false
            (inhibit_idle)
            (dnd)
            ${lib.optionalString config.j.gui.eww.bluetooth "(bluetooth)"}
            (audio)
            ${lib.optionalString config.j.gui.eww.backlight "(backlight)"}
            (temperature)
            (cpu)
            (memory)
            ${lib.optionalString config.j.gui.eww.battery.enable "(battery)"}
            (datetime)
            (tray :visible {true})))
      ''
      + (
        let
          bat = "EWW_BATTERY.${config.j.gui.eww.battery.batteryName}";
        in
        lib.optionalString config.j.gui.eww.battery.enable (
          ''
            (defwidget battery []
              (label
                :class "battery $''
          + "{${bat}.capacity < 15 ? 'urgent' : ''}"
          + ''" :text "$''
          + "{${bat}.capacity}% $"
          + "{battery_icons[${bat}.status]}"
          + ''
            "))
          ''
        )
      );

    home.packages = with pkgs; [
      playerctl
      brightnessctl
      rofi-bluetooth
    ];
  };
}
