let
  users = import ../../config/users.nix;
in
{
  home = {
    username = users.default;
    homeDirectory = "/home/${users.default}";
    stateVersion = "24.11";
  };
}
