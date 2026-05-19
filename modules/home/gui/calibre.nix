{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.gui.calibre = {
    enable = lib.mkEnableOption "Calibre" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.gui.calibre.enable {
    # Adapted from the following GH comment. Use symlinkJoin to avoid building
    # calibre locally.
    # https://github.com/Leseratte10/acsm-calibre-plugin/issues/153#issuecomment-3900166822
    home.packages =
      with pkgs;
      let
        calibre-acsm = symlinkJoin {
          name = "calibre-acsm";
          paths = [ calibre ];
          buildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/calibre \
              --set-default ACSM_LIBCRYPTO ${openssl.out}/lib/libcrypto.so \
              --set-default ACSM_LIBSSL ${openssl.out}/lib/libssl.so
          '';
        };
      in
      [
        calibre-acsm
      ];
  };
}
