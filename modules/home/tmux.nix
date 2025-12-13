{
  lib,
  config,
  rootPath,
  ...
}:
{
  options.j.tmux = {
    enable = lib.mkEnableOption "Tmux" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.tmux.enable {
    programs.tmux = {
      enable = true;
    };
    # TODO: Nixify
    xdg.configFile."tmux/tmux.conf".source = "${rootPath}/dotfiles-repo/tmux.conf";
  };
}
