{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.fprint = {
    enable = lib.mkEnableOption "Fingerprint scanner support" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.fprint.enable {
    services.fprintd.enable = true;
    # Start the service at boot
    systemd.services.fprintd = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.type = "simple";
    };
  };
}
