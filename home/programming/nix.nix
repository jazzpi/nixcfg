{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.jh.programming = {
    nix.enable = lib.mkEnableOption "Nix language support" // {
      default = true;
    };
  };

  config = lib.mkIf config.jh.programming.nix.enable {
    home.packages = with pkgs; [
      nixd
      nixfmt-rfc-style
    ];
  };
}
