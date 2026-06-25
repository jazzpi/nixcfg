{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.gui.satobs = {
    enable = lib.mkEnableOption "Satellite observation tools" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.gui.satobs.enable {
    home.packages =
      (with pkgs; [
        stellarium
        gpredict
      ])
      ++ [
        (pkgs.callPackage "${config.paths.store.pkgs}/stvid" { })
        (pkgs.callPackage "${config.paths.store.pkgs}/astroimagej" { })
      ];
  };
}
