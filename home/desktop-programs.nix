# TODO: Move to gui
{ lib, config, ... }:
{
  options.j = {
    desktop-programs.enable = lib.mkEnableOption "desktop programs" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.desktop-programs.enable {
    programs.vscode.enable = true;

    # TODO: Can we set up settings sync here?
  };
}
