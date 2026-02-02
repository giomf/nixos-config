{ inputs, ... }:

{
  flake.modules.nixos.cosmic =
    { pkgs, ... }:
    {
      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
      services.gnome.gnome-keyring.enable = false;
      # Allow wayland support in all chrome and most electron apps
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      environment.cosmic.excludePackages = with pkgs; [
        cosmic-player
        cosmic-term
        cosmic-wallpapers
        cosmic-edit
      ];
    };

  flake.modules.homeManager.cosmic =
    {
      pkgs,
      cosmic-manager,
      cosmicLib,
      ...
    }:
    let
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
          focus_follows_cursor = true;
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
            accent = mkRON "optional" {
              red = 1.0;
              green = 0.6784314;
              blue = 0.0;
            };
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
                "alacritty -e zellij attach -c TERMINAL"
              ];
              variant = "Spawn";
            };
            description = mkRON "optional" "Open Terminal";
            key = "Super+Return";
          }
          {
            action = mkRON "enum" {
              value = [
                "kitty yazi"
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
            value = "alacritty";
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
