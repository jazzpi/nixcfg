{
  config,
  pkgs,
  lib,
  host,
  ...
}:
{
  options.j.virt.host = {
    enable = lib.mkEnableOption "Virtualization host support" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.virt.host.enable {
    # https://www.reddit.com/r/NixOS/comments/177wcyi/comment/k4vok4n/
    programs.dconf.enable = true;

    users.users.${host.user.name}.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice
      adwaita-icon-theme
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [ pkgs.OVMFFull.fd ];
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
  };
}
