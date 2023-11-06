{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    google-chrome
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    profiles = {
      guif = {
        id = 0;
        name = "guif";
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          darkreader
          keepassxc-browser
        ];
      };
    };
  };
}
