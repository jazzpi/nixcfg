{
  lib,
  config,
  pkgs,
  paths,
  ...
}:
{
  options.j.slip = {
    enable = lib.mkEnableOption "SLIP configuration" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.slip.enable {
    home.packages = with pkgs; [
      net-tools
      (writeShellScriptBin "setup-slip" (builtins.readFile "${paths.store.bin}/setup-slip"))
    ];

  };
}
