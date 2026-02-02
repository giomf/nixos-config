{ ... }:

{
  flake.modules.homeManager.browsers =
    { pkgs, ... }:
    {

      home.packages = with pkgs; [
        google-chrome
      ];

      xdg = {
        enable = true;
        mimeApps = {
          enable = true;
          defaultApplications = {
            # Web browsing - firefox
            "text/html" = [ "firefox.desktop" ];
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "x-scheme-handler/about" = [ "firefox.desktop" ];
            "x-scheme-handler/unknown" = [ "firefox.desktop" ];
            "application/x-extension-htm" = [ "firefox.desktop" ];
            "application/x-extension-html" = [ "firefox.desktop" ];
            "application/x-extension-shtml" = [ "firefox.desktop" ];
            "application/xhtml+xml" = [ "firefox.desktop" ];
            "application/x-extension-xhtml" = [ "firefox.desktop" ];
            "application/x-extension-xht" = [ "firefox.desktop" ];

            # PDF - firefox
            "application/pdf" = [ "firefox.desktop" ];
            "application/x-pdf" = [ "firefox.desktop" ];
            "application/x-bzpdf" = [ "firefox.desktop" ];
            "application/x-gzpdf" = [ "firefox.desktop" ];
          };
        };
      };

      programs.firefox = {
        enable = true;
        profiles = {
          guif = {
            id = 0;
            name = "guif";
            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
              darkreader
              floccus
              keepassxc-browser
              ublock-origin
            ];
          };
        };
      };
    };

}
