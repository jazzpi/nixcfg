{
  lib,
  pkgs,
  config,
  rootPath,
  repoPath,
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
        template = "${rootPath}/bin/use-dev-flake";
        data = {
          shell_dir = "${repoPath}/shells";
        };
        asBin = true;
      })
      # ))
    ];
  };
}
