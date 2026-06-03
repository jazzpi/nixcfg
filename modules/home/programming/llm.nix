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
    };
}
