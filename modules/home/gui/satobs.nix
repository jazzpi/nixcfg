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
let
  pkgs = pkgs-stable;
in
with lib;
{
  options.j.gui.satobs = {
    enable = mkEnableOption "Satellite observation tools" // {
      default = false;
    };
    sattools = mkOption {
      type = types.str;
      default = "$HOME/dev/sattools";
      description = "Path to sattols repository";
    };
  };

  config =
    let
      cfg = config.j.gui.satobs;
    in
    mkIf cfg.enable {
      home.packages =
        (with pkgs; [
          stellarium
          gpredict
        ])
        ++ [
          (pkgs.callPackage "${paths.store.pkgs}/sattools" { })
          (pkgs.callPackage "${paths.store.pkgs}/stvid" { })
          (pkgs.callPackage "${paths.store.pkgs}/astroimagej" { })
          (pkgs.callPackage "${paths.store.pkgs}/tlescope" { })
        ];
      home.sessionVariables = {
        ST_DATADIR = "${cfg.sattools}";
        ST_COSPAR = 9914;
        ST_TLEDIR = "$HOME/tle";
      };
    };
}
