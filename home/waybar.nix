{ config, pkgs, ... }:

{
   programs.waybar = {
		enable = true;
		systemd.enable = true;
		settings = {
			mainBar = {
				layer = "top";
				position = "bottom";
				height = 30;
				modules-left = [ "sway/workspaces" ];
				modules-center = [ "tray" ];
				modules-right = [ "network" "backlight" "pulseaudio" "temperature" "battery" "clock" ];

				"tray" = {
					spacing = 3;
				};

				"sway/workspaces" = {
					disable-scroll = true;
					all-outputs = true;
				};

				"clock" = {
					format = "{:%H:%M 󰅐 %d.%m.%Y}";
				};

				"battery" = {
					interval = 20;
					format-discharging = "{icon} {capacity}%";
					format-charging = "󱐋{icon} {capacity}%";
					format-icons = ["󱊡" "󱊢" "󱊣"];
				};

				"backlight" = {
					format = "󰛨 {percent}%";
				};

				"pulseaudio" = {
					format = "󰕾 {volume}%";
					format-muted = "󰖁 {volume}%";
				};

				"temperature" = {
					critical-threshold = 85;
					format = "{icon} {temperatureC}°C";
					format-critical = " {temperatureC}°C";
					format-icons = ["" "" ""];
				};

				"network" = {
					format-ethernet = "󰈀";
					tooltip-format-ethernet = "󰈀\n󰩟 {ipaddr}\n󰕒 {bandwidthUpBytes}\n󰇚 {bandwidthUpBytes}";

					format-wifi = "{icon} {signalStrength}%";
					tooltip-format-wifi = "{icon} {essid} ({signalStrength}%)\n󰩟 {ipaddr}\n󰕒 {bandwidthUpBytes}\n󰇚 {bandwidthUpBytes}";
					format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
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
			}

			window#waybar {
				background: rgba(43, 48, 59, 0.5);
				border-bottom: 3px solid rgba(100, 114, 125, 0.5);
				color: white;
			}

			#workspaces button {
				padding: 0 5px;
				background: transparent;
				color: white;
				border-bottom: 3px solid transparent;
			}

			#workspaces button.focused {
				background: #64727D;
				border-bottom: 3px solid white;
			}

			#clock, #battery, #pulseaudio, #backlight, #temperature, #network {
				padding: 0 10px;
			}

			#temperature.critical {
				background: rgba(255, 41, 99, 0.79);
			}
		'';
	};
}