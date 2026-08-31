{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.programming.zed = {
    enable = lib.mkEnableOption "Zed";
  };

  config = lib.mkIf config.j.programming.zed.enable {
    programs.zed-editor = {
      enable = true;
      extraPackages = with pkgs; [ nil ];
    };
  };
}
