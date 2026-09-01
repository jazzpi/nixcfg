{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.programming.zed = {
    enable = lib.mkEnableOption "Zed";
  };

  config = lib.mkIf config.j.programming.zed.enable {
    programs.zed-editor = {
      enable = true;
      extraPackages = with pkgs; [
        nil
        asm-lsp
        neocmakelsp
        black
      ];
      extensions = [
        "nix"
        "toml"
        "docker-compose"
        "dockerfile"
        "one-dark-pro"
        "xml"
        "make"
        "neocmake"
        "assembly"
        "linkerscript"
        "desktop"
        "wgsl"
        "editorconfig"
      ];
      userSettings = {
        theme = "One Dark Pro";
        buffer_font_family = "Meslo LG S DZ";
        buffer_font_size = 12;
        vim_mode = true;
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        format_on_save = "on";
        relative_line_numbers = true;
        languages.Python.formatter.external = {
          command = "black";
          arguments = [
            "--stdin-filename"
            "{buffer_path}"
            "-"
          ];
        };
      };
    };
  };
}
