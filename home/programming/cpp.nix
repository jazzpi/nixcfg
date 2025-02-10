{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.jh.programming = {
    cpp.enable = lib.mkEnableOption "C++ support" // {
      default = true;
    };
  };

  # TODO: Make this a dev shell instead
  config = lib.mkIf config.jh.programming.cpp.enable {
    home.packages = with pkgs; [
      cmake
      ninja
      gcc
      boost
    ];
  };
}
