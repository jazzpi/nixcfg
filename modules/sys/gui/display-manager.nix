{
  config,
  lib,
  pkgs,
  paths,
  ...
}:
{
  options.j.gui.displayManager = {
    defaultSession = lib.mkOption {
      type = lib.types.str;
      description = "The default session to use.";
    };
  };
  config = lib.mkIf config.j.gui.enable (
    let
      background = "${paths.store.wallpapers}/default.jpg";
    in
    {
      services.displayManager = {
        enable = true;
        defaultSession = config.j.gui.displayManager.defaultSession;
        gdm.enable = true;
      };
      nixpkgs.overlays = [
        (final: prev: {
          gnome-shell = prev.gnome-shell.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              theme=$out/share/gnome-shell/gnome-shell-theme.gresource
              tmp=$(mktemp -d)
              ( cd "$tmp"
                for r in $(gresource list "$theme"); do
                  gresource extract "$theme" "$r" > "$(basename "$r")"
                done
                cp ${background} my-bg.png
                for css in gnome-shell-dark.css gnome-shell-light.css; do
                  printf '%s\n' \
                    "#lockDialogGroup { background: url('resource:///org/gnome/shell/theme/my-bg.png'); background-size: cover; background-repeat: no-repeat; }" \
                    >> "$css"
                done
                { echo '<?xml version="1.0" encoding="UTF-8"?>'
                  echo '<gresources><gresource prefix="/org/gnome/shell/theme">'
                  for f in *; do echo "  <file>$f</file>"; done
                  echo '</gresource></gresources>'
                } > theme.gresource.xml
                glib-compile-resources --target="$theme" theme.gresource.xml
              )
              rm -rf "$tmp"
            '';
          });
        })
      ];
    }
  );
}
