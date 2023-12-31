{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bemenu
    gammastep
    swaylock-effects
    sway-contrib.grimshot
    swaybg
  ];

  wayland.windowManager.hyprland =
    let
      colors = import ./colors.nix;
      focus = colors.purple;
    in
    {
      enable = true;
      extraConfig = ''
        			$mod = SUPER
        			$term = alacritty
        			$menu = bemenu-run

        			exec-once = light -N 10
        			exec-once = nm-applet --indicator
        			exec-once = nextcloud
        			exec-once = swaybg --mode fill --image ${./wallpaper.png}

        			bind = $mod, return, exec, $term -e zellij attach -c TERMINAL
        			bind = $mod, space, exec, $menu
        			bind = $mod SHIFT, return, exec, firefox
        			bind = $mod, F, exec, $term -e joshuto
        			bind = $mod, K, exec, keepassxc
        			bind = $mod, M, exec, thunderbird
        			bind = $mod, T, exec, $term -e btop
        			bind = $mod, L, exec, grimshot copy area
        			bind = $mod, C, exec, $term -e numbat
        			bind = $mod, J, exec, bash -c if pgrep gammastep; then pkill gammastep; else gammastep -O 4500; fi
        			bind = $mod, escape, exec, ${pkgs.swaylock-effects}/bin/swaylock -f -S --clock --effect-blur 10x10 --fade-in 1

        			binde = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
        			binde = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
        			binde = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
        			binde = , XF86MonBrightnessUp, exec, light -A 10
        			binde = , XF86MonBrightnessDown, exec, light -U 10


        			# move focus
        			bind = $mod, left, movefocus, l
        			bind = $mod, right, movefocus, r
        			bind = $mod, up, movefocus, u
        			bind = $mod, down, movefocus, d
        			bind = $mod, A, movefocus, l
        			bind = $mod, D, movefocus, r
        			bind = $mod, W, movefocus, u
        			bind = $mod, S, movefocus, d

        			# move window
        			bind = $mod SHIFT, left, movewindow, l
        			bind = $mod SHIFT, right, movewindow, r
        			bind = $mod SHIFT, up, movewindow, u
        			bind = $mod SHIFT, down, movewindow, d
        			bind = $mod SHIFT, A, movewindow, l
        			bind = $mod SHIFT, D, movewindow, r
        			bind = $mod SHIFT, W, movewindow, u
        			bind = $mod SHIFT, S, movewindow, d

        			bind = $mod, Q, killactive,
        			bind = $mod, E, fullscreen, 1

        			# workspaces
        			# binds mod + [shift +] {1..10} to [move to] ws {1..10}
        			${builtins.concatStringsSep "\n" (builtins.genList (
        				x: let
        				ws = let
        					c = (x + 1) / 10;
        				in
        					builtins.toString (x + 1 - (c * 10));
        				in ''
        				bind = $mod, ${ws}, workspace, ${toString (x + 1)}
        				bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
        				''
        			)
        			10)}


        			##########################################################################

        			general {
        				border_size = 2
        				gaps_out = 5
        				gaps_in = 5
        				col.active_border = rgb(${focus})
        			}

        			input {
        				kb_layout = de
        			}

        			gestures {
        				workspace_swipe = true
        				workspace_swipe_fingers = 3
        			}

        			misc {
        				disable_hyprland_logo = true
        			}

        			debug {
            			overlay = false
        			}

        			decoration {
        				drop_shadow = false
        				blur {
        					enabled = false
        				}
        			}

        			monitor=,highres,auto,1
        			monitor=DP-2,2560x1440@60,auto,1

        		'';
    };

  services.swayidle =
    let
      output_on_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      output_off_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
      suspend_cmd = "${pkgs.systemd}/bin/systemctl suspend";
      lock_sleep_cmd = "${pkgs.swaylock-effects}/bin/swaylock -f -S --clock --effect-blur 10x10";
      lock_idle_cmd = "${pkgs.swaylock-effects}/bin/swaylock -f -S --clock --effect-blur 10x10 --fade-in 3 --grace 10";
    in
    {
      enable = true;
      systemdTarget = "hyprland-session.target";
      events = [
        { event = "before-sleep"; command = "${lock_sleep_cmd}"; }
      ];
      timeouts = [
        { timeout = 300; command = "${lock_idle_cmd}"; }
        { timeout = 600; command = "${output_off_cmd}"; resumeCommand = "${output_on_cmd}"; }
        { timeout = 900; command = "${suspend_cmd}"; }
      ];
    };
}
