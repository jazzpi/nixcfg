{ host, ... }:
{
  imports = [
    ./programming
    ./shell.nix
    ./personal.nix
    ./networking.nix
    ./gui
    ./work
    ./drive-sync.nix
    ./tmux.nix
    ./ssh.nix
    ./slip.nix
    ./yazi.nix
    ./sdr.nix
  ];

  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home = {
      username = host.user.name;
      homeDirectory = "/home/${host.user.name}";

      # nh hides activation output by default, which makes failures undebuggable
      sessionVariables.NH_SHOW_ACTIVATION_LOGS = "1";
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
