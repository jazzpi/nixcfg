{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.gui.im =
    let
      mkMessenger = (
        {
          configName,
          name,
          pkg,
          exec,
          icon,
        }:
        {
          ${configName} = {
            enable = lib.mkEnableOption "${name}" // {
              default = false;
            };
            autostart = lib.mkEnableOption "${name} autostart" // {
              default = config.j.gui.im.${configName}.enable;
            };
            pkg = lib.mkOption {
              type = lib.types.package;
              default = pkg;
              description = "Package for ${name}.";
            };
            exec = lib.mkOption {
              type = lib.types.str;
              default = exec;
              description = "Command to execute ${name}.";
            };
            icon = lib.mkOption {
              type = lib.types.str;
              default = icon;
              description = "Icon for ${name}.";
            };
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "Name of the messenger (${name}).";
            };
          };
        }
      );
    in
    lib.mergeAttrsList (
      map mkMessenger [
        {
          name = "Slack";
          configName = "slack";
          pkg = pkgs.slack;
          # TODO: What if we run on X11?
          # TODO: Why is this needed? Nix starts it with --ozone-platform-hint=auto anyway,
          # which used to be enough. But now it seems to start with XWayland for some reason.
          exec = "${pkgs.slack}/bin/slack --ozone-platform=wayland";
          icon = "slack";
        }
        {
          name = "Signal";
          configName = "signal";
          pkg = pkgs.signal-desktop;
          exec = "${pkgs.signal-desktop}/bin/signal-desktop --password-store=gnome-libsecret";
          icon = "signal-desktop";
        }
        {
          name = "Telegram";
          # TODO: The .desktop file should have a different name I think. Icon also seems to be wrong.
          configName = "telegram";
          pkg = pkgs.telegram-desktop;
          exec = "${pkgs.telegram-desktop}/bin/Telegram";
          icon = "telegram-desktop";
        }
        {
          name = "Discord";
          configName = "discord";
          pkg = pkgs.discord;
          exec = "${pkgs.discord}/bin/discord";
          icon = "discord";
        }
        {
          name = "Element";
          configName = "element";
          pkg = pkgs.element-desktop;
          exec = "${pkgs.element-desktop}/bin/element-desktop";
          icon = "element-desktop";
        }
      ]
    );

  config =
    let
      cfg = config.j.gui.im;
      enabled = lib.filterAttrs (name: x: x.enable) cfg;
    in
    {
      home.packages = lib.mapAttrsToList (name: x: x.pkg) enabled;
      xdg.desktopEntries = builtins.mapAttrs (name: x: {
        name = x.name;
        exec = x.exec;
        icon = x.icon;
      }) enabled;
      xdg.autostart.entries = lib.mapAttrsToList (
        name: x: "${config.home.homeDirectory}/.nix-profile/share/applications/${name}.desktop"
      ) (lib.filterAttrs (name: x: x.autostart) enabled);
    };
}
