{
  pkgs,
  lib,
  config,
  rootPath,
  ...
}:
{
  options.j.programming.git = {
    enable = lib.mkEnableOption "Git utilities" // {
      default = config.j.programming.enable;
    };
    copilot = lib.mkEnableOption "GitHub Copilot CLI" // {
      default = config.j.programming.enable;
    };
  };

  config = lib.mkIf config.j.programming.git.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "git-add-id" (builtins.readFile "${rootPath}/dotfiles-repo/bin/git-add-id"))
      (writeShellScriptBin "git-use-id" (builtins.readFile "${rootPath}/dotfiles-repo/bin/git-use-id"))
    ];

    programs.git = {
      enable = true;
      ignores = [
        ".envrc"
        ".direnv"
        ".mypy_cache/"
        ".ccls-cache/"
        ".auctex-auto/"
        "__pycache__/"
        "compile_commands.json"
        "*.aux"
        "*.fdb_latexmk"
        "*.fls"
        "*.out"
        "*.synctex.gz"
        ".python-version"
      ];
      extraConfig = {
        push.autoSetupRemote = true;
        user.useconfigonly = true;
        init.defaultBranch = "main";
      };
    };
    programs.gh = lib.mkIf config.j.programming.git.copilot {
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
