{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.j.gui.nvidia.enable {
    hardware = {
      graphics = {
        enable = true; # OpenGL
        enable32Bit = true;
        extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      };
      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = false; # Doesn't play well with Wayland and Electron
        nvidiaSettings = true;
      };
    };
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
