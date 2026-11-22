{ inputs, ... }:

{
  flake-file.inputs.cosmic-manager = {
    url = "github:HeitorAugustoLN/cosmic-manager";
    inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
      home-manager.follows = "home-manager-unstable";
    };
  };

  flake.modules.nixos.cosmic =
    { pkgs, ... }:
    {
      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
      services.gnome.gnome-keyring.enable = false;
      services.desktopManager.cosmic.showExcludedPkgsWarning = false;
      # Allow wayland support in all chrome and most electron apps
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      environment.cosmic.excludePackages = with pkgs; [
        cosmic-edit
        cosmic-initial-setup
        cosmic-player
        cosmic-reader
        cosmic-term
        cosmic-wallpapers
      ];
    };

  flake.modules.homeManager.cosmic =
    {
      config,
      pkgs,
      cosmic-manager,
      cosmicLib,
      ...
    }:
    let
      # Stylix base16 color as a COSMIC srgb value
      c = config.lib.stylix.colors;
      rgb = base: {
        red = builtins.fromJSON c."${base}-dec-r";
        green = builtins.fromJSON c."${base}-dec-g";
        blue = builtins.fromJSON c."${base}-dec-b";
      };
      rgba = base: rgb base // { alpha = 1.0; };
      screenshot_script = pkgs.writeShellApplication {
        runtimeInputs = with pkgs; [
          satty
          wl-clipboard
        ];
        name = "screenshot.sh";
        text = ''
          filename=$(cosmic-screenshot --interactive=false -s /tmp)
          satty -f "$filename" \
                --fullscreen \
                --initial-tool crop \
                --actions-on-right-click save-to-clipboard \
                --copy-command wl-copy \
                --early-exit
        '';
      };
    in
    {
      imports = [
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
      ];

      wayland.desktopManager.cosmic = with cosmicLib.cosmic; {

        enable = true;
        resetFiles = false;
        compositor = {
          autotile = true;
          active_hint = true;
          focus_follows_cursor = false;
          worksoace_mode = mkRON "enum" "Global";
          xkb_config = {
            layout = "de";
            model = "";
            options = mkRON "optional" "None";
            repeat_delay = 600;
            repeat_rate = 25;
            rules = "";
            variant = "";
          };
        };

        applets.time.settings = {
          military_time = true;
          first_day_of_week = 0;
        };

        appearance = {
          theme.mode = "dark";
          theme.dark = {
            # Colors follow the stylix scheme (base16 roles)
            accent = mkRON "optional" (rgb "base0A");
            bg_color = mkRON "optional" (rgba "base00");
            primary_container_bg = mkRON "optional" (rgba "base01");
            secondary_container_bg = mkRON "optional" (rgba "base02");
            neutral_tint = mkRON "optional" (rgb "base03");
            text_tint = mkRON "optional" (rgb "base05");
            destructive = mkRON "optional" (rgb "base08");
            warning = mkRON "optional" (rgb "base09");
            success = mkRON "optional" (rgb "base0B");
            corner_radii = {
              radius_0 = mkRON "tuple" [
                0.0
                0.0
                0.0
                0.0
              ];
              radius_l = mkRON "tuple" [
                2.0
                2.0
                2.0
                2.0
              ];
              radius_m = mkRON "tuple" [
                8.0
                8.0
                8.0
                8.0
              ];
              radius_s = mkRON "tuple" [
                8.0
                8.0
                8.0
                8.0
              ];
              radius_xl = mkRON "tuple" [
                8.0
                8.0
                8.0
                8.0
              ];
              radius_xs = mkRON "tuple" [
                8.0
                8.0
                8.0
                8.0
              ];
            };
          };
          toolkit = {
            apply_theme_global = true;
            show_maximize = false;
            show_minimize = false;
            # Same fonts as fontconfig in font.nix (COSMIC defaults to Inter / JetBrains Mono)
            interface_font = {
              family = "Fira Sans";
              stretch = mkRON "enum" "Normal";
              style = mkRON "enum" "Normal";
              weight = mkRON "enum" "Normal";
            };
            monospace_font = {
              family = "FiraCode Nerd Font Mono";
              stretch = mkRON "enum" "Normal";
              style = mkRON "enum" "Normal";
              weight = mkRON "enum" "Normal";
            };
          };
        };

        shortcuts = [
          {
            action = mkRON "enum" {
              value = [
                "firefox"
              ];
              variant = "Spawn";
            };
            description = mkRON "optional" "Open Firefox";
            key = "Super+Shift+Return";
          }
          {
            action = mkRON "enum" {
              value = [
                "rio -e zellij attach -c TERMINAL"
              ];
              variant = "Spawn";
            };
            description = mkRON "optional" "Open Terminal";
            key = "Super+Return";
          }
          {
            action = mkRON "enum" {
              value = [
                "rio -e yazi"
              ];
              variant = "Spawn";
            };
            description = mkRON "optional" "Open TUI Filebrowser";
            key = "Super+F";
          }
          # Currently have to set the launcher manualy due to some bugs
          {
            action = mkRON "enum" {
              value = [
                "cosmic-launcher"
              ];
              variant = "Spawn";
            };
            description = mkRON "optional" "Launcher";
            key = "Super+Space";
          }
          {
            action = mkRON "enum" "Maximize";
            key = "Super+E";
          }
          {
            action = mkRON "enum" {
              value = [
                "${screenshot_script}/bin/screenshot.sh"
              ];
              variant = "Spawn";
            };
            description = mkRON "optional" "Screenshot";
            key = "Super+P";
          }
        ];

        systemActions = mkRON "map" [
          {
            key = mkRON "enum" "Terminal";
            value = "rio";
          }
          {
            key = mkRON "enum" "Launcher";
            value = "krunner";
          }
        ];

        panels = [
          {
            name = "Panel";
            anchor = mkRON "enum" "Bottom";
            anchor_gap = false;
            autohide = mkRON "optional" null;
            background = mkRON "enum" "Dark";
            expand_to_edges = true;
            opacity = 1.0;
            output = mkRON "enum" "All";
            margin = 4;
            plugins_center = mkRON "optional" [
              "com.system76.CosmicAppletStatusArea"
            ];
            plugins_wings = mkRON "optional" (
              mkRON "tuple" [
                [
                  "com.system76.CosmicAppletPower"
                  "com.system76.CosmicAppletWorkspaces"
                ]
                [
                  "com.system76.CosmicAppletTiling"
                  "com.system76.CosmicAppletAudio"
                  "com.system76.CosmicAppletBluetooth"
                  "com.system76.CosmicAppletNetwork"
                  "com.system76.CosmicAppletNotifications"
                  "com.system76.CosmicAppletBattery"
                  "com.system76.CosmicAppletTime"
                ]
              ]
            );
            size = mkRON "enum" "XS";
          }
        ];
      };
    };

}
