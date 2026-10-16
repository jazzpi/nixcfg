{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.j.ollama;
in
{
  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      # ollama-cuda isn't in the binary cache and takes ages to build; Vulkan works on NVIDIA too.
      package = pkgs.ollama-vulkan;
      loadModels = [ cfg.editPredictionModel ];
      environmentVariables = {
        OLLAMA_KEEP_ALIVE = "10m";
        OLLAMA_CONTEXT_LENGTH = "4096";
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
      };
    };
  };
}
