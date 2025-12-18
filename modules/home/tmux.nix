{
  lib,
  config,
  paths,
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
    xdg.configFile."tmux/tmux.conf".source = "${paths.store.dots-repo}/tmux/tmux.conf";
  };
}
