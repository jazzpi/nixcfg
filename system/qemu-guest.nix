{ pkgs, lib, config, ... }: {
  options = {
    j.qemu-guest.enable = lib.mkEnableOption "QEMU guest config";
  };

  config = lib.mkIf config.j.qemu-guest.enable {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
    services.spice-webdavd.enable = true;
  };
}
