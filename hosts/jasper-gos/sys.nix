{ lib, inputs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "24.11";

  j.boot.loader = "systemd-boot";
  j.boot.initrdBluetooth = false;
  j.virt = {
    docker = {
      enable = true;
      rootless = false;
      addToDockerGroup = true;
    };
    host.enable = true;
  };
  j.gui.i3.enable = true;
  j.networking.wireguard = true;
  j.networking.can = true;
  j.networking.tftp = true;

  j.gui.logic.enable = true;
  j.gui.wireshark.enable = true;

  j.gui.steam.enable = true;

  j.udev.limesdr = true;

  # Enable SSHD to install it
  services.sshd.enable = true;
  # Override the service's wantedBy to prevent it from starting on boot
  systemd.services.sshd.wantedBy = lib.mkForce [ ];

  j.gui.displayManager.defaultSession = "niri-uwsm";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.udev.packages = [ inputs.waveforms.packages.${builtins.currentSystem}.adept2-runtime ];
  environment.systemPackages = [ inputs.waveforms.packages.${builtins.currentSystem}.waveforms ];

  services.postgresql.enable = true;

  # Bypass kcryptd workqueue (under write bursts, this bottlenecks on fast NVMe drives)
  boot.initrd.luks.devices."luks-0e8748e2-96fb-4f02-9d47-1f7795ab0dd4".crypttabExtraOpts = [
    "no-read-workqueue"
    "no-write-workqueue"
  ];
}
