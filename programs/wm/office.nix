{
  ...
}:
{
  flake.modules.homeManager.office =
    { pkgs, ... }:
    {
      xdg = {
        enable = true;
        mimeApps = {
          enable = true;
          defaultApplications = {
            # Images - feh
            "image/png" = [ "feh.desktop" ];
            "image/jpeg" = [ "feh.desktop" ];
            "image/gif" = [ "feh.desktop" ];
            "image/webp" = [ "feh.desktop" ];
            "image/tiff" = [ "feh.desktop" ];
            "image/bmp" = [ "feh.desktop" ];
            "image/x-icon" = [ "feh.desktop" ];
            "image/x-xcf" = [ "feh.desktop" ];
            "image/svg+xml" = [ "feh.desktop" ];
            "image/x-photoshop" = [ "feh.desktop" ];
            "image/x-portable-anymap" = [ "feh.desktop" ];
            "image/x-portable-bitmap" = [ "feh.desktop" ];
            "image/x-portable-graymap" = [ "feh.desktop" ];
            "image/x-portable-pixmap" = [ "feh.desktop" ];
            "image/x-xbitmap" = [ "feh.desktop" ];
            "image/x-xpixmap" = [ "feh.desktop" ];
            "image/heif" = [ "feh.desktop" ];
            "image/heic" = [ "feh.desktop" ];

            # Videos - VLC
            "video/mp4" = [ "vlc.desktop" ];
            "video/x-matroska" = [ "vlc.desktop" ];
            "video/webm" = [ "vlc.desktop" ];
            "video/mpeg" = [ "vlc.desktop" ];
            "video/ogg" = [ "vlc.desktop" ];
            "video/quicktime" = [ "vlc.desktop" ];
            "video/x-msvideo" = [ "vlc.desktop" ];
            "video/x-flv" = [ "vlc.desktop" ];
            "video/x-ms-wmv" = [ "vlc.desktop" ];
            "video/3gpp" = [ "vlc.desktop" ];
            "video/3gpp2" = [ "vlc.desktop" ];
            "video/mp2t" = [ "vlc.desktop" ];
            "video/x-ogm+ogg" = [ "vlc.desktop" ];

            # Audio - VLC
            "audio/mpeg" = [ "vlc.desktop" ];
            "audio/mp4" = [ "vlc.desktop" ];
            "audio/ogg" = [ "vlc.desktop" ];
            "audio/flac" = [ "vlc.desktop" ];
            "audio/x-wav" = [ "vlc.desktop" ];
            "audio/x-vorbis+ogg" = [ "vlc.desktop" ];
            "audio/x-opus+ogg" = [ "vlc.desktop" ];
            "audio/webm" = [ "vlc.desktop" ];
            "audio/aac" = [ "vlc.desktop" ];
            "audio/x-aac" = [ "vlc.desktop" ];
            "audio/x-flac" = [ "vlc.desktop" ];
            "audio/x-matroska" = [ "vlc.desktop" ];
            "audio/x-ape" = [ "vlc.desktop" ];
            "audio/x-mp3" = [ "vlc.desktop" ];
            "audio/x-mpeg" = [ "vlc.desktop" ];

            # Email - Thunderbird
            "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
            "message/rfc822" = [ "thunderbird.desktop" ];
            "application/x-extension-eml" = [ "thunderbird.desktop" ];
            "application/x-xpinstall" = [ "thunderbird.desktop" ];
            "text/calendar" = [ "thunderbird.desktop" ];
            "application/x-extension-ics" = [ "thunderbird.desktop" ];
            "x-scheme-handler/webcal" = [ "thunderbird.desktop" ];
            "x-scheme-handler/webcals" = [ "thunderbird.desktop" ];
            "application/vnd.mozilla.xul+xml" = [ "thunderbird.desktop" ];
            "text/directory" = [ "thunderbird.desktop" ];
            "text/x-vcard" = [ "thunderbird.desktop" ];
            "application/mbox" = [ "thunderbird.desktop" ];
          };
        };
      };

      home.packages = with pkgs; [
        feh
        gimp
        keepassxc
        obsidian
        onlyoffice-desktopeditors
        thunderbird
        vlc
        xournalpp
      ];
    };
}
