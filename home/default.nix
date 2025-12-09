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
    ../private/home
  ];

  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home = {
      username = host.user.name;
      homeDirectory = "/home/${host.user.name}";
    };
  };
}
