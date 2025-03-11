{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.programming.cpp = {
    enable = lib.mkEnableOption "C++ support" // {
      default = config.j.programming.enable;
    };
  };

  # TODO: Make this a dev shell instead
  config = lib.mkIf config.j.programming.cpp.enable {
    home.packages = with pkgs; [
      cmake
      ninja
      gcc
      boost
    ];
  };
}
