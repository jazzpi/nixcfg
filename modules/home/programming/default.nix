{
  lib,
  pkgs,
  config,
  paths,
  templateFile,
  ...
}:
{
  imports = [
    ./nix.nix
    ./cpp.nix
    ./git.nix
    ./direnv.nix
    ./vscode.nix
    ./emacs.nix
  ];

  options.j.programming.enable = lib.mkEnableOption "Programming support" // {
    default = true;
  };

  config = lib.mkIf config.j.programming.enable {
    home.packages = with pkgs; [
      man-pages
      man-pages-posix
      (templateFile {
        name = "use-dev-flake";
        template = "${paths.store.bin}/use-dev-flake";
        data = {
          shell_dir = "${paths.repo.shells}";
        };
        asBin = true;
      })
    ];
  };
}
