{
  lib,
  config,
  ...
}:
{
  options.j.gui.nvidia = {
    enable = lib.mkEnableOption "Nvidia drivers" // {
      default = false;
    };
  };
  config = lib.mkIf config.j.gui.nvidia.enable {
    hardware = {
      graphics.enable = true; # OpenGL
      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = true;
        nvidiaSettings = true;
      };
    };
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
