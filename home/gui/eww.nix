{
  pkgs,
  lib,
  config,
  rootPath,
  templateFile,
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
    };
    xdg.configFile."eww/eww.yuck".source = "${rootPath}/dotfiles/eww/eww.yuck";
    xdg.configFile."eww/eww.scss".source = "${rootPath}/dotfiles/eww/eww.scss";
    xdg.configFile."eww/scripts".source = "${rootPath}/dotfiles/eww/scripts";
    xdg.configFile."eww/widgets/battery.yuck".source = (
      templateFile {
        name = "battery.yuck";
        template = "${rootPath}/dotfiles/eww/widgets/battery.mustache.yuck";
        data = {
          bat = "EWW_BATTERY.${config.j.gui.eww.battery.batteryName}";
        };
      }
    );
    xdg.configFile."eww/widgets/right-info.yuck".source = (
      templateFile {
        name = "right-info.yuck";
        template = "${rootPath}/dotfiles/eww/widgets/right-info.mustache.yuck";
        data = {
          bluetooth = ''${lib.optionalString config.j.gui.eww.bluetooth "(bluetooth)"}'';
          battery = ''${lib.optionalString config.j.gui.eww.battery.enable "(battery)"}'';
          backlight = ''${lib.optionalString config.j.gui.eww.backlight "(backlight)"}'';
        };
      }
    );

    home.packages = with pkgs; [
      playerctl
      brightnessctl
      rofi-bluetooth
    ];
  };
}
