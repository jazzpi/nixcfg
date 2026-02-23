{ lib, config, ... }:
with lib;
{
  options = {
    j.gui.uwsm.compositors = mkOption {
      type =
        with types;
        attrsOf (submodule {
          options = {
            name = mkOption {
              type = str;
              description = "A user-friendly name for the compositor.";
            };
            binPath = mkOption {
              type = path;
              description = "The path to the compositor binary.";
            };
            extraArgs = mkOption {
              type = listOf str;
              default = [ ];
              description = "Additional arguments to pass to the compositor.";
            };
          };
        });
      default = { };
      description = "Additional Wayland compositors to add to UWSM.";
    };
  };
  config = mkIf config.j.gui.uwsm.enable {
    programs.uwsm = {
      enable = true;
      waylandCompositors = (
        mapAttrs (key: value: {
          prettyName = value.name;
          comment = "UWSM-managed ${value.name}";
          binPath = value.binPath;
          extraArgs = value.extraArgs;
        }) config.j.gui.uwsm.compositors
      );
    };
  };
}
