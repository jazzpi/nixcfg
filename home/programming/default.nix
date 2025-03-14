{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./nix.nix
    ./cpp.nix
    ./git.nix
    ./direnv.nix
    ./vscode.nix
  ];

  options.j.programming.enable = lib.mkEnableOption "Programming support" // {
    default = true;
  };

  config = lib.mkIf config.j.programming.enable {
    home.packages = with pkgs; [
      man-pages
      man-pages-posix
    ];
  };
}
