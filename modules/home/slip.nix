{
  lib,
  config,
  pkgs,
  rootPath,
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
      (writeShellScriptBin "setup-slip" (builtins.readFile "${rootPath}/bin/setup-slip"))
    ];

  };
}
