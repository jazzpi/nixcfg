{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.programming.nix = {
    enable = lib.mkEnableOption "Nix language support" // {
      default = config.j.programming.enable;
    };
  };

  config = lib.mkIf config.j.programming.nix.enable {
    home.packages = with pkgs; [
      nixd
      nixfmt
    ];
  };
}
