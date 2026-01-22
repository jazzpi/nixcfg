{
  pkgs,
  lib,
  config,
  paths,
  ...
}:
{
  options.j.programming.git = {
    enable = lib.mkEnableOption "Git utilities" // {
      default = config.j.programming.enable;
    };
  };

  config = lib.mkIf config.j.programming.git.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "git-add-id" (builtins.readFile "${paths.store.dots-repo}/bin/git-add-id"))
      (writeShellScriptBin "git-use-id" (builtins.readFile "${paths.store.dots-repo}/bin/git-use-id"))
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
        ".cache/"
        "compile_commands.json"
        "*.aux"
        "*.fdb_latexmk"
        "*.fls"
        "*.out"
        "*.synctex.gz"
        ".python-version"
      ];
      settings = {
        push.autoSetupRemote = true;
        user.useconfigonly = true;
        init.defaultBranch = "main";
      };
    };
  };
}
