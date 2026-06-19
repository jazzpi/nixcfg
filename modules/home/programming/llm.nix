{
  lib,
  config,
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
    in
    mkIf cfg.enable {
      programs.claude-code = {
        enable = true;
        skills = "${paths.store.llm}/skills/";
      };

      # Normally, the SKILLS.md files are created as symlinks to the nix store. That works
      # fine on the host, but if I mount ~/.claude into a devcontainer, the symlinks break
      # of course. So instead, we copy the files fully.

      # Delete the copied files so home-manager can create its symlinks
      home.activation.prepareClaudeSkills = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        for skillDir in "${paths.store.llm}/skills"/*/; do
          [ -d "$skillDir" ] || continue
          skillName="$(basename "$skillDir")"
          find "${config.programs.claude-code.configDir}/skills/$skillName" \
            -not -type d -not -type l 2>/dev/null -delete || true
        done
      '';

      # Turn the symlinks into full copies
      home.activation.dereferenceClaudeSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        find "${config.programs.claude-code.configDir}/skills" -type l 2>/dev/null | \
        while IFS= read -r link; do
          real="$(readlink -f "$link")"
          [ -f "$real" ] && cp --no-preserve=mode "$real" "$link.new" && mv "$link.new" "$link"
        done
      '';
    };
}
