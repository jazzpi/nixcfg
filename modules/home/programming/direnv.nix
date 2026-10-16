{
  lib,
  config,
  ...
}:
{
  options.j.programming.direnv = {
    enable = lib.mkEnableOption "Direnv support (for dev shells)" // {
      default = config.j.programming.enable;
    };
  };

  config = lib.mkIf config.j.programming.direnv.enable {
    programs.direnv = {
      enable = true;
      # Hooked manually below
      enableBashIntegration = false;
      nix-direnv.enable = true;
    };

    # distrobox shares $HOME (and thus .bashrc) with the host, but host flakes break inside the
    # container.
    programs.bash.initExtra = lib.mkAfter ''
      if [ -z "''${CONTAINER_ID:-}" ]; then
        eval "$(${lib.getExe config.programs.direnv.package} hook bash)"
      fi
    '';
  };
}
