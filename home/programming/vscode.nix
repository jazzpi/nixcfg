{
  pkgsu,
  lib,
  config,
  ...
}:
{
  options.j.programming.code = {
    enable = lib.mkEnableOption "VSCode" // {
      default = config.j.programming.enable && config.j.gui.enable;
    };
  };

  config = lib.mkIf config.j.programming.code.enable {
    programs.vscode = {
      enable = true;
      package = pkgsu.vscode.fhs;
    };
  };
}
