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
  };

  config = lib.mkIf config.jh.programming.git.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "git-add-id" (builtins.readFile "${rootPath}/dotfiles-repo/bin/git-add-id"))
      (writeShellScriptBin "git-use-id" (builtins.readFile "${rootPath}/dotfiles-repo/bin/git-use-id"))
    ];
  };
}
