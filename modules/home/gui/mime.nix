{ lib, config, ... }:
{
  options.j.gui.mime = {
    enable = lib.mkEnableOption "MIME types" // {
      default = config.j.gui.enable;
    };
    defaults = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      description = ''
        Default applications for MIME types.

        Keys are MIME types, values are lists of desktop files.

        For each entry, an association is added and the default application is
        set.
      '';
    };
  };

  config =
    let
      cfg = config.j.gui.mime;
    in
    lib.mkIf cfg.enable {
      xdg.mimeApps = {
        enable = true;
        associations.added = cfg.defaults;
        defaultApplications = cfg.defaults;
      };
    };
}
