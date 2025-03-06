let
  users = import ./users.nix;
in
{
  nixos-vm = {
    hostname = "nixos-vm";
    dir = "nixos-vm";
    arch = "x86_64-linux";
    user = users.default;
  };
  jasper-gos = {
    hostname = "jasper-gos";
    dir = "jasper-gos";
    arch = "x86_64-linux";
    user = users.default;
  };
  jasper-desk = {
    hostname = "jasper-desk";
    dir = "jasper-desk";
    arch = "x86_64-linux";
    user = users.default;
  };
}
