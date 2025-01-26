{ lib, config, ... }:
{
  options.jh = {
    desktop-programs.enable = lib.mkEnableOption "desktop programs" // {
      default = true;
    };
  };

  config = lib.mkIf config.jh.desktop-programs.enable {
    programs.vscode.enable = true;

    # TODO: Can we set up settings sync here?
  };
}
