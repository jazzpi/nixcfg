{
  pkgs,
  lib,
  config,
  rootPath,
  ...
}:
{
  options.jh.programming.git = {
    enable = lib.mkEnableOption "Git utilities" // {
      default = true;
    };
    copilot = lib.mkEnableOption "GitHub Copilot CLI" // {
      default = true;
    };
  };

  config = lib.mkIf config.jh.programming.git.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "git-add-id" (builtins.readFile "${rootPath}/dotfiles-repo/bin/git-add-id"))
      (writeShellScriptBin "git-use-id" (builtins.readFile "${rootPath}/dotfiles-repo/bin/git-use-id"))
    ];

    programs.git = {
      enable = true;
      ignores = [
        ".envrc"
        ".direnv"
      ];
    };
    programs.gh = lib.mkIf config.jh.programming.git.copilot {
      enable = true;
      extensions = with pkgs; [
        gh-copilot
      ];
      settings.aliases = {
        s = "copilot suggest -t shell";
      };
    };
  };
}
