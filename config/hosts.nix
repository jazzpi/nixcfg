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
}
