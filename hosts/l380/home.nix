{ config, pkgs, agenix, ... }:

{
  imports = [
    ../../home
    ../../home/wm
  ];

  home.packages = with pkgs; [
    agenix.packages.${system}.default 
  ];
}
