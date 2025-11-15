{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.programs.enable = lib.mkEnableOption "default system programs" // {
    default = true;
  };

  config = lib.mkIf config.j.programs.enable {
    programs.firefox.enable = lib.mkDefault true;
    programs.vim.enable = lib.mkDefault true;
    programs.git.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      # Install home-manager standalone. The manual tells you to install it imperatively, but that
      # kinda defeats the purpose of NixOS?
      home-manager
      # Install various CLI utils
      jq
      python3
      usbutils
      pciutils
      libnotify
      nh
      btop
      dig
      socat
      unzip
      file
      bc
      lsof
      net-tools
    ];
  };
}
