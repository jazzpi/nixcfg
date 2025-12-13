{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.gui.sioyek = {
    enable = lib.mkEnableOption "Sioyek" // {
      default = config.j.gui.enable;
    };
  };

  config = lib.mkIf config.j.gui.sioyek.enable {
    programs.sioyek = {
      enable = true;
      bindings = {
        "next_page" = "<C-f>";
        "previous_page" = "<C-b>";
      };
      config = {
        "page_separator_width" = "2";
        "page_separator_color" = "0.5 0.5 0.5";
        "control_click_command" = "synctex_under_cursor";
        "collapsed_toc" = "1";
      };
    }
    # Without this, sioyek fails to create the EGL context.
    // lib.optionalAttrs config.j.gui.nvidia.enable {
      package = pkgs.symlinkJoin {
        name = "sioyek";
        paths = [ pkgs.sioyek ];
        buildInputs = [
          pkgs.makeWrapper
          pkgs.libglvnd
        ];
        postBuild = ''
          wrapProgram $out/bin/sioyek \
            --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json
        '';
      };
    };
  };
}
