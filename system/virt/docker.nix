{
  lib,
  config,
  host,
  ...
}:
{
  options.j.virt.docker = {
    enable = lib.mkEnableOption "Docker support" // {
      default = false;
    };
    rootless = lib.mkEnableOption "Rootless Docker" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.virt.docker.enable {
    virtualisation.docker = {
      enable = true;
      rootless = lib.mkIf config.j.virt.docker.rootless {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          debug = true;
        };
      };
    };
    users.users.${host.user}.extraGroups = lib.mkIf (!config.j.virt.docker.rootless) [ "docker" ];
  };
}
