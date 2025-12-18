{
  config,
  paths,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.j.networking.enable {
    home.packages =
      with pkgs;
      lib.optionals config.j.networking.can [
        (writeShellScriptBin "setup-slcan" (builtins.readFile "${paths.store.bin}/setup-slcan"))
      ];
  };
}
