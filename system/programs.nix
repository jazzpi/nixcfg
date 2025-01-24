{ pkgs, lib, config, ... }: {
  options = {
    j.programs.enable = lib.mkEnableOption "default system programs" // { default = true; };
  };

  config = lib.mkIf config.j.programs.enable {
    programs.firefox.enable = lib.mkDefault true;
    programs.vim.enable = lib.mkDefault true;
    programs.git.enable = lib.mkDefault true;
  };
}
