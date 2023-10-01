{ config, pkgs, ... }:

{
	home.stateVersion = "23.05";
	home.username = "giom";
	home.homeDirectory = "/home/giom";

	# Packages
	home.packages = with pkgs; [
		# Base
		alacritty
		ranger
		pavucontrol
		pulseaudio
		zellij
		eza
		bat
		flameshot
		btop
		unzip

		# DE
		bemenu
		gammastep
		swaylock-effects

		# Coding
		git
		rustup

		# Office
		google-chrome
		libreoffice-qt
		keepassxc
		thunderbird
		
		# Social
		telegram-desktop
		element-desktop
		discord
		spotify
		nextcloud-client
	];


	# Programs
	programs.fish = {
		enable = true;
		shellInit = "
			set -g __fish_git_prompt_show_informative_status true
			set -g __fish_git_prompt_showstashstate true
			set -g __fish_git_prompt_showupstream informative
			set -g __fish_git_prompt_showcolorhints true
			set -g __fish_git_prompt_showuntrackedfiles true
			set -g __fish_git_prompt_describe_style branch

			set -g __fish_git_prompt_char_untrackedfiles +
			set -g __fish_git_prompt_color_untrackedfiles green

			set -g __fish_git_prompt_char_dirtystate ⌁
			set -g __fish_git_prompt_color_dirtystate yellow

			set -g __fish_git_prompt_char_stashstate ⚑
			set -g __fish_git_prompt_color_stashstate blue

			set -g __fish_git_prompt_color_branch --bold white

			set -g __fish_git_prompt_color_upstream yellow
			set -g __fish_git_prompt_char_upstream_diverged ↕
			set -g __fish_git_prompt_char_upstream_prefix \" \"

			set -g __fish_git_prompt_color_cleanstate green
		";
		shellAliases = {
			# ls = eza
			"ls" = "eza -lbghF";
			"ll" = "eza -lbghF";
			"la" = "eza -lbghFa";
			"lt" = "eza --tree --level=2";
			# cat = bat
			"cat" = "bat";
		};
		functions = {
			cd = "builtin cd $argv && eza -l --no-time";
			fish_greeting = "";
			fish_right_prompt = "date '+%H:%M:%S'";
			fish_prompt = "printf '[%s@%s%s%s]%s %s%s%s\n> ' $USER (set_color red) (prompt_hostname) (set_color normal) (fish_git_prompt) (set_color green) (prompt_pwd) (set_color normal)";
		};
	};

	programs.vim = {
		enable = true;
		defaultEditor = true;
	};

	programs.vscode = {
		enable = true;
		enableUpdateCheck = false;
		mutableExtensionsDir = false;
		extensions = with pkgs.vscode-extensions; [
			jnoortheen.nix-ide
			rust-lang.rust-analyzer
			streetsidesoftware.code-spell-checker
			arrterian.nix-env-selector
			mads-hartmann.bash-ide-vscode
			foxundermoon.shell-format
		];
		userSettings = {
			"workbench.colorTheme" = "Visual Studio Dark";
			"window.zoomLevel" = 2;
			"editor.tabSize" = 4;
			"editor.indentSize" = "tabSize";
			"editor.minimap.enabled" = false;
			"[nix]"."editor.tabSize" = 4;
			"nixEnvSelector.nixFile" = "\${workspaceRoot}/shell.nix";
		};
	};

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

	programs.firefox = {
		enable = true;
		package = pkgs.firefox-wayland;
		profiles = {
			giom = {
				id = 0;
				name = "giom";
				extensions = with pkgs.nur.repos.rycee.firefox-addons; [
					ublock-origin
					darkreader
					keepassxc-browser
				];
			};
		};
	};

	# Services
	services.ssh-agent.enable = true;
	services.blueman-applet.enable = true;

	## Notification daemon
	services.mako = {
		enable = true;
		defaultTimeout = 7500;
		maxVisible = 3;
	};

	services.swayidle = 
		let	
			output_on_cmd = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
			output_off_cmd = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
			lock_sleep_cmd = "${pkgs.swaylock-effects}/bin/swaylock -f -S --clock --effect-blur 10x10";
			lock_idle_cmd = "${pkgs.swaylock-effects}/bin/swaylock -f -S --clock --effect-blur 10x10 --fade-in 3 --grace 10";
		in {
			enable = true;
			events = [
				{ event = "before-sleep"; command = "${lock_sleep_cmd}"; }
			];
			timeouts = [
				{ timeout = 300; command = "${lock_idle_cmd}"; }
				{ timeout = 600; command = "${output_off_cmd}"; resumeCommand = "${output_on_cmd}"; }
			];
		};

	# Window manager
	wayland.windowManager.sway = {
		enable = true;
		xwayland = true;
		config = rec {
			modifier = "Mod4";
			terminal = "alacritty";
			menu = "bemenu-run";
			defaultWorkspace = "workspace number 1";
			input = {
				"*" = {
					xkb_layout = "de";
				};
			};
				fonts = {
				names = [ "DejaVu Sans Mono" ];
				size = 11.0;
			};
				gaps = {
				smartBorders = "on";
			};
			startup = [
				{ command = "nextcloud"; }
			];
			bars = [];
			keybindings = {
				"${modifier}+Return" = "exec --no-startup-id ${terminal} -e zellij attach -c TERMINAL";
				"${modifier}+Space" = "exec --no-startup-id ${menu}";
				"${modifier}+Shift+Return" = "exec --no-startup-id firefox";
				"${modifier}+f" = "exec --no-startup-id ${terminal} -e ranger";
				"${modifier}+k" = "exec --no-startup-id keepassxc";
				"${modifier}+m" = "exec --no-startup-id thunderbird";
				"${modifier}+l" = "exec --no-startup-id flameshot gui";
				"${modifier}+t" = "exec --no-startup-id ${terminal} -e btop";
				"${modifier}+j" = "exec --no-startup-id bash -c \"if pgrep gammastep; then pkill gammastep; else gammastep -O 4500; fi\"";
				"${modifier}+Escape" = "exec --no-startup-id ${pkgs.swaylock-effects}/bin/swaylock -f -S --clock --effect-blur 10x10 --fade-in 1";

				"XF86AudioMute" =  "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
				"XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
				"XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
				"XF86MonBrightnessUp" = "exec light -A 10";
				"XF86MonBrightnessDown" = "exec LIGHT=$(light) && (( \${LIGHT%.*} > 10 )) && light -U 10";

				"${modifier}+Up" = "focus up";
				"${modifier}+w" = "focus up";
				"${modifier}+Down" = "focus down";
				"${modifier}+s" = "focus down";
				"${modifier}+Left" = "focus left";
				"${modifier}+a" = "focus left";
				"${modifier}+Right" = "focus right";
				"${modifier}+d" = "focus right";

				"${modifier}+Shift+Up" = "move up";
				"${modifier}+Shift+w" = "move up";
				"${modifier}+Shift+Down" = "move down";
				"${modifier}+Shift+s" = "move down";
				"${modifier}+Shift+Left" = "move left";
				"${modifier}+Shift+a" = "move left";
				"${modifier}+Shift+Right" = "move right";
				"${modifier}+Shift+d" = "move right";

				"${modifier}+Shift+1" = "move container to workspace number 1";
				"${modifier}+Shift+2" = "move container to workspace number 2";
				"${modifier}+Shift+3" = "move container to workspace number 3";
				"${modifier}+Shift+4" = "move container to workspace number 4";
				"${modifier}+Shift+5" = "move container to workspace number 5";
				"${modifier}+Shift+6" = "move container to workspace number 6";
				"${modifier}+Shift+7" = "move container to workspace number 7";
				"${modifier}+Shift+8" = "move container to workspace number 8";
				"${modifier}+Shift+9" = "move container to workspace number 9";
				"${modifier}+Shift+0" = "move container to workspace number 10";

				"${modifier}+e" = "layout tabbed";
				"${modifier}+Tab" = "layout toggle tabbed split";
				"${modifier}+q" = "kill";

				"${modifier}+1" = "workspace number 1";
				"${modifier}+2" = "workspace number 2";
				"${modifier}+3" = "workspace number 3";
				"${modifier}+4" = "workspace number 4";
				"${modifier}+5" = "workspace number 5";
				"${modifier}+6" = "workspace number 6";
				"${modifier}+7" = "workspace number 7";
				"${modifier}+8" = "workspace number 8";
				"${modifier}+9" = "workspace number 9";
				"${modifier}+0" = "workspace number 10";

				"${modifier}+Shift+r" = "reload";
				"${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
			};
		};
	};

  	# Let Home Manager install and manage itself.
  	programs.home-manager.enable = true;
}
