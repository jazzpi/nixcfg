{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.jh.qalc = {
    enable = lib.mkEnableOption "Qalculate!" // {
      default = true;
    };
  };

  config = lib.mkIf config.jh.qalc.enable {
    home.packages = with pkgs; [
      qalculate-gtk
    ];
  };
}
