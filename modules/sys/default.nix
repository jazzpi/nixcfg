{
  lib,
  host,
  ...
}:
{
  imports = [
    ./networking.nix
    ./programs.nix
    ./audio.nix
    ./boot.nix
    ./udev.nix
    ./fprint.nix
    ./printing.nix
    ./gui
    ./virt
  ];

  options.j = {
    location = lib.mkOption {
      type = with lib.types; attrsOf (either str float);
      default = {
        provider = "geoclue2";
      };
    };
  };

  config = {
    # Use flakes
    nix = {
      gc = {
        automatic = true;
        randomizedDelaySec = "15min";
        options = "--delete-older-than 30d";
      };
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [ "@wheel" ];
      };
    };
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

    # Give me /bin/bash
    services.envfs.enable = true;

    # TODO: Move to a "laptop.nix"?
    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    services.orca.enable = false;
    services.speechd.enable = false;
  };
}
