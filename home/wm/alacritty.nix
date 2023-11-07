{ config, pkgs, ... }:

{
  
#  home.packages = with pkgs; [
#    alacritty-theme
#  ];

  programs.alacritty = {
    enable = true;
  };
}
