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
        cups-pdf = {
          enable = true;
          instances.pdf = {
            settings = {
              Out = "\${HOME}/cups-pdf";
            };
          };
        };
      };
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
