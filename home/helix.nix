{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    nil
    nodePackages_latest.bash-language-server
    python311Packages.python-lsp-server
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
      };
    };
  };
}
