{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-doom-emacs-unstraightened.homeModule ];

  options.j.programming.magit.enable = lib.mkEnableOption "Standalone Magit (Doom Emacs)" // {
    default = config.j.programming.git.enable;
  };

  config = lib.mkIf config.j.programming.magit.enable {
    programs.doom-emacs = {
      enable = true;
      doomDir = ./doom.d;
      doomLocalDir = "${config.xdg.stateHome}/doom-magit";
      profileName = "magit";
      # Keep this isolated: don't claim the `emacs`/`emacsclient` binaries.
      provideEmacs = false;
    };

    home.packages = [
      (pkgs.writeShellScriptBin "magit" ''
        exec ${config.programs.doom-emacs.finalDoomPackage}/bin/doom-emacs -nw --eval '(progn (require (quote magit)) (magit-status default-directory))'
      '')
    ];
  };
}
