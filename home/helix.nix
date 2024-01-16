{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    nil
    nodePackages_latest.bash-language-server
    python311Packages.python-lsp-server
    rust-analyzer
  ];
  
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "github_dark_dimmed";
      editor = {
        line-number = "relative";
        rulers = [120];
        mouse = false;
        statusline = {
          left = ["mode" "spinner" "version-control"];
          center = ["file-base-name" "file-modification-indicator" "diagnostics"];
          right = ["selections" "position" "total-line-numbers"];
        };
        lsp = {
          display-messages = true;
        };
      };
    };
  };
}
