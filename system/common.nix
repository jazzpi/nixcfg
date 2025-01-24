{ pkgs, lib, config, ... }: {
  options = {
    j.common.enable = lib.mkEnableOption "common system config" // { default = true; };
  };

  config = lib.mkIf config.j.common.enable {
    # Use flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    boot.loader.grub.enable = true;
    boot.loader.grub.useOSProber = true;

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

    networking.networkmanager.enable = true;
    # TODO: networking.wireless.enable ?

    time.timeZone = "Europe/Berlin";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_TIME = "en_DK.UTF-8"; # For ISO8601 goodness
    };

    services.xserver.enable = true;
    services.xserver.xkb = {
      layout = "us";
      variant = "altgr-intl";
    };
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    # TODO: Enable i3

    services.printing.enable = true;

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };

    # TODO: Move to a "laptop.nix"?
    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
  };
}
