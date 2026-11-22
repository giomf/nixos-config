{
  ...
}:
{
  flake.modules.homeManager.office =
    { pkgs, config, ... }:
    let
      c = config.lib.stylix.colors.withHashtag;
      stylixColors = ''
        :root {
          --layout-background-0: ${c.base00} !important;
          --layout-background-1: ${c.base01} !important;
          --layout-background-2: ${c.base01} !important;
          --layout-background-3: ${c.base02} !important;
          --layout-background-4: ${c.base02} !important;
          --layout-color-0: ${c.base06} !important;
          --layout-color-1: ${c.base05} !important;
          --layout-color-2: ${c.base04} !important;
          --layout-color-3: ${c.base03} !important;
          --layout-border-0: ${c.base02} !important;
          --layout-border-1: ${c.base03} !important;
          --toolbar-bgcolor: ${c.base01} !important;
          --toolbar-color: ${c.base05} !important;
          --toolbar-field-background-color: ${c.base00} !important;
          --toolbar-field-color: ${c.base05} !important;
          --sidebar-background: ${c.base01} !important;
          --sidebar-background-color: ${c.base01} !important;
          --sidebar-text-color: ${c.base05} !important;
          --tree-view-bg: ${c.base00} !important;
          --tree-card-background: ${c.base00} !important;
          --tree-pane-background: ${c.base00} !important;
          --tree-view-color: ${c.base05} !important;
          --selected-item-color: ${c.base0D} !important;
          --selected-item-text-color: ${c.base00} !important;
          --treeitem-background-active: ${c.base0D} !important;
          --treeitem-background-selected: ${c.base02} !important;
          --treeitem-background-hover: ${c.base01} !important;
          --color-primary-default: ${c.base0D} !important;
        }
      '';
    in
    {
      # The profile folder must be ~/.thunderbird/guif: rename the old random one (e.g. chyfyeiy.default)
      # once per machine and delete ~/.thunderbird/profiles.ini, home-manager writes it now
      programs.thunderbird = {
        enable = true;
        profiles.guif = {
          isDefault = true;
          settings."toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          # TEMPORARY: once https://github.com/nix-community/stylix/pull/2529 (stylix thunderbird target) is merged,
          # drop stylixColors, userChrome, userContent and the stylesheets setting here and enable
          # stylix.targets.thunderbird (profileNames = [ "guif" ]) in stylix.nix instead.
          # Stylix colors for the Thunderbird UI, like cosmic.nix does for COSMIC. userChrome covers the window
          # frame, userContent the panes (about:3pane, about:message, address book are separate pages).
          # !important: user sheets lose to Thunderbird's own sheets otherwise
          userChrome = stylixColors;
          userContent = stylixColors;
        };
      };

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
        onlyoffice-desktopeditors
        vlc
        xournalpp
        wifi-qr
      ];
    };
}
