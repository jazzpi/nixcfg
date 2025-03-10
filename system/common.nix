{
  lib,
  config,
  ...
}:
{
  options = {
    j.common.enable = lib.mkEnableOption "common system config" // {
      default = true;
    };
    j.common.location = lib.mkOption {
      type = with lib.types; attrsOf (either string float);
      default = {
        provider = "geoclue2";
      };
    };
  };

  config = lib.mkIf config.j.common.enable {
    # Use flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nixpkgs.config.allowUnfree = true;

    # TODO: This should pull from /config/users.nix
    users.users.jasper = {
      isNormalUser = true;
      description = "Jasper";
      extraGroups = [
        "networkmanager"
        "wheel"
        "plugdev"
        "dialout"
        "wireshark"
        "docker"
      ];
    };

    time.timeZone = "Europe/Berlin";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_TIME = "en_DK.UTF-8"; # For ISO8601 goodness
    };

    # TODO: Move to gui
    services.xserver.enable = true;
    services.xserver.xkb = {
      layout = "us";
      variant = "altgr-intl";
    };
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Give me /bin/bash
    services.envfs.enable = true;

    services.printing.enable = true;

    # TODO: Move to a "laptop.nix"?
    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
  };
}
