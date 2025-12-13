{
  lib,
  config,
  ...
}:
{
  options.j.virt.qemu-guest.enable = lib.mkEnableOption "QEMU guest config" // {
    default = false;
  };

  config = lib.mkIf config.j.virt.qemu-guest.enable {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
    services.spice-webdavd.enable = true;
  };
}
