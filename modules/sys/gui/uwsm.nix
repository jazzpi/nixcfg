{ lib, config, ... }:
with lib;
{
  options = {
    j.gui.uwsm.compositors = mkOption {
      type = with types; attrsOf (attrsOf str);
      default = { };
      description = ''
        Additional Wayland compositors to add to UWSM.
        The key is the compositor ID, the value is an attribute set with the following keys:
        - name: A user-friendly name for the compositor.
        - binPath: The path to the compositor binary.
      '';
    };
  };
  config = mkIf config.j.gui.uwsm.enable {
    programs.uwsm = {
      enable = true;
      waylandCompositors = (
        (mapAttrs (key: value: {
          prettyName = value.name;
          comment = "UWSM-managed ${value.name}";
          binPath = value.binPath;
        }) config.j.gui.uwsm.compositors)
      );
    };
  };
}
