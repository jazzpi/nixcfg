{ lib, host, ... }:
{
  imports = [
    ./networking.nix
    ./programs.nix
    ./audio.nix
    ./boot.nix
    ./udev.nix
    ./gui
    ./virt
  ];

  options.j = {
    location = lib.mkOption {
      type = with lib.types; attrsOf (either string float);
      default = {
        provider = "geoclue2";
      };
    };
  };

  config = {
    # Use flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nixpkgs.config.allowUnfree = true;

    networking.hostName = host.name;
    users.users.${host.user.name} = {
      isNormalUser = true;
      description = host.user.description or (lib.toSentenceCase host.user.name);
      extraGroups = host.user.groups or [ ];
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
