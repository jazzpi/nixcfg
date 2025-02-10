{ lib, ... }:
{
  # There's nothing to configure here ATM, but we use this option e.g. for the
  # personal firefox profile
  options.j.personal = {
    enable = lib.mkEnableOption "Personal" // {
      default = false;
    };
  };
}
