{
  lib,
  config,
  ...
}:
{
  options.jh.sioyek = {
    enable = lib.mkEnableOption "Sioyek" // {
      default = true;
    };
  };

  config = lib.mkIf config.jh.sioyek.enable {
    programs.sioyek = {
      enable = true;
      bindings = {
        "next_page" = "<C-f>";
        "previous_page" = "<C-b>";
      };
      config = {
        "page_separator_width" = "2";
        "page_separator_color" = "0.5 0.5 0.5";
        "control_click_command" = "synctex_under_cursor";
      };
    };
  };
}
