{ lib, config, ... }:
{
  options.j.ssh = {
    enable = lib.mkEnableOption "SSH configuration" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          setEnv = lib.optionalAttrs config.j.gui.kitty.enable {
            TERM = "xterm-256color";
          };
        };
      };
    };
    # Home Manager creates the config file in the Nix store (owned by root:root
    # with 444 permissions) and then symlinks to it from ~/.ssh/config. This
    # causes problems in FHS envs (e.g. VSCode). See
    # https://github.com/nix-community/home-manager/issues/322#issuecomment-2265239792
    home.file.".ssh/config" = {
      target = ".ssh/config_source";
      onChange = ''cat ~/.ssh/config_source > ~/.ssh/config && chmod 600 ~/.ssh/config'';
    };
    systemd.user.tmpfiles.settings = {
      sshControlPaths = {
        rules."%t/ssh-controlpaths".D = {
          mode = "0700";
        };
      };
    };
  };
}
