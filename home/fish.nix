{ config, ... }:

{
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
}