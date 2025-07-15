{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.printing = {
    enable = lib.mkEnableOption "Printing support" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.printing.enable {
    services = {
      printing = {
        enable = true;
        drivers = with pkgs; [
          epson-escpr
          epson-escpr2
        ];
      };
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
