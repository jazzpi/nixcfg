{
  lib,
  config,
  pkgs,
  ...
}:
let
  mkFirefoxProfile =
    {
      name,
      id,
      enable,
    }:
    {
      ${if enable then name else null} = {
        id = id;
        isDefault = (config.j.gui.firefox.defaultProfile == name);

        settings = {
          # Disable first-run stuff
          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "browser.uitour.enabled" = false;

          "browser.toolbars.bookmarks.visibility" = "always";
          "browser.tabs.inTitlebar" = 0;
        };
      };
    };
  mkFirefoxProfileDesktopEntry =
    {
      name,
      enable,
      ...
    }:
    {
      ${if enable then "firefox-${name}" else null} = {
        name = "Firefox (${name})";
        genericName = "Web Browser";
        exec = "${pkgs.firefox}/bin/firefox -P \"${name}\" %U";
        icon = "${pkgs.firefox}/lib/firefox/browser/chrome/icons/default/default128.png";
        categories = [
          "Application"
          "Network"
          "WebBrowser"
        ];
        mimeType = [
          "text/html"
          "text/xml"
        ];
      };
    };
  ffProfilePersonal = {
    name = "personal";
    id = 0;
    enable = config.j.personal.enable;
  };
  ffProfileWork = {
    name = "work";
    id = 1;
    enable = config.j.work.enable;
  };
  numFFProfiles = builtins.length (builtins.attrNames config.programs.firefox.profiles);
in
{
  options.j.gui.firefox = {
    enable = lib.mkEnableOption "Firefox Browser" // {
      default = true;
    };
    defaultProfile = lib.mkOption {
      type = lib.types.enum [
        "personal"
        "work"
      ];
      default = "personal";
    };
  };
  # TODO: Chrome for Google Meet etc

  config = lib.mkIf config.j.gui.firefox.enable {
    # TODO: Create a list of profiles and iterate over it
    programs.firefox = {
      enable = true;
      profiles = { } // mkFirefoxProfile ffProfilePersonal // mkFirefoxProfile ffProfileWork;
    };

    xdg.desktopEntries = lib.mkIf (numFFProfiles > 1) (
      { } // mkFirefoxProfileDesktopEntry ffProfilePersonal // mkFirefoxProfileDesktopEntry ffProfileWork
    );
  };
}
