{
  config,
  rootPath,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.j.networking.enable {
    home.packages =
      with pkgs;
      lib.optionals config.j.networking.can [
        (writeShellScriptBin "setup-slcan" (builtins.readFile "${rootPath}/scripts/setup-slcan"))
      ];
  };
}
