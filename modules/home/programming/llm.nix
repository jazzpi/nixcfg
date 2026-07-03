{
  lib,
  config,
  pkgs,
  inputs,
  paths,
  ...
}:
with lib;
{
  options.j.programming.llm = {
    enable = mkEnableOption "LLM utilities";
  };

  config =
    let
      cfg = config.j.programming.llm;
      llmPkgs = inputs.llm-agents.packages.${pkgs.system};
    in
    mkIf cfg.enable {
      home.packages = [ llmPkgs.ccstatusline ];

      programs.claude-code = {
        enable = true;
        package = llmPkgs.claude-code;
        skills = "${paths.store.llm}/skills/";
        settings = {
          tui = "fullscreen";
          statusLine = {
            type = "command";
            command = "${llmPkgs.ccstatusline}/bin/ccstatusline";
            refreshInterval = 10;
          };
        };
      };

      xdg.configFile."ccstatusline/settings.json".text = builtins.toJSON {
        version = 3;
        lines = [
          [
            {
              id = "1";
              type = "model";
              color = "cyan";
              rawValue = true;
            }
            {
              id = "2";
              type = "thinking-effort";
              backgroundColor = "bgBrightBlack";
              rawValue = true;
            }
            {
              id = "3";
              type = "context-bar";
              color = "brightBlack";
              rawValue = false;
              metadata = {
                display = "slider";
              };
            }
            {
              id = "5";
              type = "session-usage";
              color = "magenta";
              metadata = {
                display = "slider";
              };
            }
            {
              id = "7";
              type = "reset-timer";
              color = "yellow";
            }
            {
              id = "a504f78d-2b75-4058-bd3e-956e8298c828";
              type = "session-cost";
              backgroundColor = "bgBrightRed";
              rawValue = true;
            }
          ]
        ];
        flexMode = "full-minus-40";
        compactThreshold = 60;
        colorLevel = 2;
        inheritSeparatorColors = false;
        globalBold = false;
        minimalistMode = false;
        powerline = {
          enabled = true;
          separators = [
            ""
          ];
          separatorInvertBackground = [ false ];
          startCaps = [ ];
          endCaps = [ ];
          autoAlign = false;
          continueThemeAcrossLines = false;
          theme = "nord-aurora";
        };
        defaultPadding = " ";
      };

      # Normally, the SKILLS.md files and settings.json are created as symlinks to the nix
      # store. That works fine on the host, but if I mount ~/.claude into a devcontainer,
      # the symlinks break of course. So instead, we copy/merge the files fully.

      # Delete the copied files so home-manager can create its symlinks.
      # For settings.json, save the existing file so we can merge it back later.
      home.activation.prepareClaudeSkills = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        for skillDir in "${paths.store.llm}/skills"/*/; do
          [ -d "$skillDir" ] || continue
          skillName="$(basename "$skillDir")"
          find "${config.programs.claude-code.configDir}/skills/$skillName" \
            -not -type d -not -type l 2>/dev/null -delete || true
        done

        settingsFile="${config.programs.claude-code.configDir}/settings.json"
        if [ -f "$settingsFile" ] && [ ! -L "$settingsFile" ]; then
          cp "$settingsFile" "$settingsFile.pre-hm"
          rm "$settingsFile"
        fi
      '';

      # Turn the symlinks into full copies.
      # For settings.json, merge the saved user settings with the nix-generated ones
      # (nix wins on conflicting keys), then write back as a regular file.
      home.activation.dereferenceClaudeSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        find "${config.programs.claude-code.configDir}/skills" -type l 2>/dev/null | \
        while IFS= read -r link; do
          real="$(readlink -f "$link")"
          [ -f "$real" ] && cp --no-preserve=mode "$real" "$link.new" && mv "$link.new" "$link"
        done

        settingsFile="${config.programs.claude-code.configDir}/settings.json"
        if [ -L "$settingsFile" ]; then
          nixSettings="$(readlink -f "$settingsFile")"
          if [ -f "$settingsFile.pre-hm" ]; then
            merged="$(${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$settingsFile.pre-hm" "$nixSettings")"
            rm "$settingsFile.pre-hm"
          else
            merged="$(cat "$nixSettings")"
          fi
          printf '%s\n' "$merged" > "$settingsFile.new"
          mv "$settingsFile.new" "$settingsFile"
        fi
      '';
    };
}
