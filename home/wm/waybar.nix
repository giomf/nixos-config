{ config, pkgs, ... }:

{
  programs.waybar =
    let
      colors = import ./colors.nix;
      bar_base = colors.grey_dark;
      bar_items = colors.grey_light;
      bar_highlights = colors.blue;
      power_button = colors.red;
      text = colors.white;
      focus = colors.purple;
      warning = colors.orange;
      critical = colors.red;
    in
    {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "bottom";
          height = 30;
          modules-left = [ "custom/power" "hyprland/workspaces" ];
          modules-center = [ "tray" ];
          modules-right = [ "network" "backlight" "pulseaudio" "temperature" "battery" "clock" ];

          "tray" = {
            icon-size = 20;
            spacing = 3;
          };

          "custom/power" = {
            format = "󰐥";
            on-click = "systemctl poweroff";
            on-click-right = "systemctl reboot";
          };

          "hyprland/workspaces" = {
            all-outputs = true;
          };

          "clock" = {
            format = "{:%H:%M 󰅐 %d.%m.%Y}";
          };

          "battery" = {
            interval = 20;
            format-discharging = "{icon} {capacity}%";
            format-charging = "󱐋{icon} {capacity}%";
            format-icons = [ "󱊡" "󱊢" "󱊣" ];
            states = {
              "warning" = 50;
              "critical" = 25;
            };
          };

          "backlight" = {
            format = "󰛨 {percent}%";
          };

          "pulseaudio" = {
            format = "󰕾 {volume}%";
            format-muted = "󰖁 {volume}%";
          };

          "temperature" = {
            hwmon-path = "/sys/class/hwmon/hwmon5/temp1_input";
            critical-threshold = 80;
            format = "{icon} {temperatureC}°C";
            format-critical = " {temperatureC}°C";
            format-icons = [ "" "" "" ];
          };

          "network" = {
            format-ethernet = "󰈀";
            tooltip-format-ethernet = "󰈀\n󰩟 {ipaddr}\n󰕒 {bandwidthUpBytes}\n󰇚 {bandwidthDownBytes}";

            format-wifi = "{icon} {signalStrength}%";
            tooltip-format-wifi = "{icon} {essid} ({signalStrength}%)\n󰩟 {ipaddr}\n󰕒 {bandwidthUpBytes}\n󰇚 {bandwidthDownBytes}";
            format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
          };
        };
      };
      style = ''
        			* {
        				border: none;
        				border-radius: 0;
        				font-family: Roboto, Helvetica, Arial, sans-serif;
        				font-size: 13px;
        				min-height: 0;
        				color: #${text};
        			}

        			window#waybar {
        				background: #${bar_base};
        			}

        			#workspaces button {
        				margin: 3px 0;
        			}

        			#workspaces button.active {
        				margin: 3px 0;
        				border-radius: 5;
        				background: #${focus};
        			}

        			#clock, #battery, #pulseaudio, #backlight, #temperature, #network, #custom-power {
        				padding: 0 10px;
        				margin: 3px;
        				background: #${bar_items};
        				border-radius: 5;
        			}

        			#custom-power, #clock {
        				background: #${bar_highlights};
        			}

        			#battery.warning {
        				background: #${warning};
        			}

        			#battery.critical {
        				background: #${critical};
        			}

        			#temperature.critical {
        				background: #${critical};
        			}

        			#pulseaudio.muted {
        				background: #${critical};
        			}
        		'';
    };
}
