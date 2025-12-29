{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    {
      # We manage the cache ourselves in flake.nix
      niri-flake.cache.enable = false;
    }
    (lib.mkIf config.j.gui.niri.enable {
      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };
    })
  ];
}
