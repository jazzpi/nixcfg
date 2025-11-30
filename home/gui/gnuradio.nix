{
  config,
  pkgs,
  lib,
  rootPath,
  ...
}:
with lib;
{
  options.j.gui.gnuradio = {
    enable = mkEnableOption "GNU Radio" // {
      default = false;
    };
  };

  config = mkIf config.j.gui.gnuradio.enable (
    let
      gr-satellites = pkgs.callPackage "${rootPath}/packages/gr-satellites" { };
      gnuradioWithDeps = pkgs.symlinkJoin {
        name = "gnuradio-with-gr-satellites";
        paths = [
          pkgs.gnuradio
          gr-satellites
        ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          for prog in $out/bin/*; do
            if [ -f "$prog" ] && [ -x "$prog" ]; then
              wrapProgram "$prog" \
                --prefix PYTHONPATH : "${gr-satellites}/lib/python${pkgs.gnuradio.python.pythonVersion}/site-packages" \
                --prefix GRC_BLOCKS_PATH : "${gr-satellites}/share/gnuradio/grc/blocks"
            fi
          done
        '';
      };
    in
    {
      home.packages = [
        gnuradioWithDeps
      ];
    }
  );
}
