{
  lib,
  config,
  pkgs,
  inputs,
  paths,
  templateFile,
  ...
}:
with lib;
{
  options.j.programming.llm = {
    enable = mkEnableOption "LLM utilities";
    plugins = mkOption {
      type = types.listOf types.str;
      default = [ "superpowers@claude-plugins-official" ];
      description = "List of Claude Code plugins to install";
    };
  };

  config =
    let
      cfg = config.j.programming.llm;
      llmPkgs = inputs.llm-agents.packages.${pkgs.system};

      home = config.home.homeDirectory;
      # Source checkouts the research subagents grep. Read-only; kept as stable clones
      # (not nix-store inputs, whose paths change on every ./update).
      nixpkgsSrc = "${home}/dev/nixpkgs";
      hmSrc = "${home}/dev/home-manager";
      # Writable, git-tracked knowledge base the researchers append to (see llm/knowledge).
      knowledgeDir = "${home}/nixcfg/llm/knowledge";

      # The claude-code module's `agents` option only treats a literal `path` as a file
      # source; a derivation falls through to its `text` branch. So we render with
      # templateFile and read the result back as a string (IFD).
      renderAgent =
        name: data:
        builtins.readFile (templateFile {
          name = "${name}.md";
          template = "${paths.store.llm}/agents/${name}.md.mustache";
          inherit data;
        });

      # Shared, read-only substrate of cross-cutting Nix/flake/lib semantics. Owned by the
      # orchestrator; the research subagents read it but never write to it.
      nixKnowledgeDir = "${knowledgeDir}/nix";

      researchAgents = {
        home-manager-researcher = renderAgent "home-manager-researcher" {
          inherit hmSrc nixKnowledgeDir;
          knowledgeDir = "${knowledgeDir}/home-manager";
        };
        nixpkgs-researcher = renderAgent "nixpkgs-researcher" {
          inherit nixpkgsSrc nixKnowledgeDir;
          knowledgeDir = "${knowledgeDir}/nixpkgs";
        };
      };
    in
    mkIf cfg.enable {
      home.packages = [ llmPkgs.ccstatusline ];

      programs.claude-code = {
        enable = true;
        package = llmPkgs.claude-code;
        skills = "${paths.store.llm}/skills/";
        agents = researchAgents;

        # Options/package search — the cheap path for "does this option exist / what's its
        # type". When the docs are too shallow to implement something, hand off to the
        # home-manager-researcher / nixpkgs-researcher subagents instead.
        mcpServers.nixos = {
          type = "stdio";
          command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        };
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
      home.activation.prepareClaude = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
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

      # Plugins loaded via the module's own `plugins`/`marketplaces` options
      # only show up as session-only (--plugin-dir) and are invisible to any
      # `claude` invocation that isn't launched through the Nix-wrapped binary
      # (e.g. inside a devcontainer that mounts ~/.claude but runs its own
      # claude install).
      home.activation.installClaudePlugins = lib.hm.dag.entryAfter [ "installPackages" ] ''
        ${config.programs.claude-code.finalPackage}/bin/claude plugin install superpowers@claude-plugins-official \
          >/dev/null || echo "Warning: failed to install superpowers Claude Code plugin" >&2
      '';

      # Turn the symlinks into full copies.
      # For settings.json, merge the saved user settings with the nix-generated ones
      # (nix wins on conflicting keys), then write back as a regular file.
      home.activation.dereferenceClaude = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        # home-manager's activation script hardcodes PATH to a minimal toolset that
        # doesn't include git; `claude plugin install` (below) shells out to a bare
        # `git` to clone plugin repos, so put it back on PATH for this whole script.
        export PATH="${lib.makeBinPath [ pkgs.git ]}:$PATH"

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

        for plugin in ${lib.concatStringsSep " " cfg.plugins}; do
          ${config.programs.claude-code.package}/bin/claude plugin install "$plugin"
        done
      '';
    };
}
