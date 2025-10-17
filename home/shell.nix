{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.shell.enable = lib.mkEnableOption "Shell configuration" // {
    default = true;
  };

  config = lib.mkIf config.j.shell.enable {
    programs.bash.enable = true;
    programs.bash.enableCompletion = true;
    programs.bash.enableVteIntegration = true;
    programs.bash.historyControl = [
      "ignorespace"
      "ignoredups"
    ];
    programs.bash.shellOptions = [
      "histappend"
      "globstar"
      "dotglob"
    ];
    programs.bash.shellAliases = {
      la = "ls -lAh";
      ll = "ls -lh";
      l = "ls -A --group-directories-first";

      gco = "git checkout";
      gst = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gf = "git fetch";
      gl = "git pull";
      glg = "git log";
      ga = "git add";

      grep = "grep --color=auto";
    };

    xdg.configFile."bash/bashrc-extra".source = ../dotfiles/bashrc-extra;
    programs.bash.initExtra = "source ${config.xdg.configHome}/bash/bashrc-extra";

    # ~/.inputrc config
    programs.readline.enable = true;
    programs.readline.bindings = {
      "\\e[A" = "history-search-backward";
      "\\e[B" = "history-search-forward";
    };

    programs.fd = {
      enable = true;
      hidden = true;
    };
    programs.ripgrep.enable = true;

    nixpkgs.config = import ./nixpkgs.nix;
    xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs.nix;

    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    home.packages = [
      pkgs.shfmt
    ];
  };
}
