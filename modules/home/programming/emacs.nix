{
  pkgs,
  pkgs-stable,
  lib,
  config,
  ...
}:
{
  options.j.programming.emacs = {
    enable = lib.mkEnableOption "Emacs" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.programming.emacs.enable {
    home.packages =
      (with pkgs; [
        emacs
        emacs-all-the-icons-fonts
      ])
      # I only really use Emacs for TeX
      ++ (with pkgs-stable; [
        texliveFull
      ]);
    # TODO: Doom Emacs setup
  };
}
