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

    # Install home-manager standalone. The manual tells you to install it imperatively, but that
    # kinda defeats the purpose of NixOS?
    environment.systemPackages = with pkgs; [
      home-manager
      jq
      python3
      usbutils
      libnotify
      nh
    ];
  };
}
