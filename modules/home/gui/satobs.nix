{
  lib,
  config,
  pkgs-stable,
  paths,
  ...
}:
# FIXME: soapy-uhd is broken on unstable, so sdr.nix uses pkgs-stable. Since we
# install gpredict in sdr.nix and here, we need to use matching nixpkgs
# versions.
let pkgs = pkgs-stable; in
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
        (pkgs.callPackage "${paths.store.pkgs}/stvid" { })
        (pkgs.callPackage "${paths.store.pkgs}/astroimagej" { })
        (pkgs.callPackage "${paths.store.pkgs}/tlescope" { })
      ];
  };
}
