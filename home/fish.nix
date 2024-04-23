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

      # Force truecolor support for wsl
      set -gx COLORTERM truecolor
			
			bind \\ef fzf-file-widget
			bind \\ed fzf-cd-widget
			bind \\er fzf-history-widget
		";
    shellAliases = {
      # ls = eza
      "la" = "eza -lbgha -F";
      "ll" = "eza -lbghF";
      "ls" = "eza -lbghF";
      "lt" = "eza -lbghF --tree --level=2";

      # cat = bat
      "cat" = "bat";

      # git
      "gca" = "git commit -a";
      "gch" = "git checkout";
      "gdf" = "git diff";
      "glg" = "git log --decorate --graph --pretty=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%ad%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''            %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%n' --date=local --all";
      "gph" = "git push";
      "gpr" = "git pull --rebase";
      "gre" = "git rebase";
      "gst" = "git status";
    };
    functions = {
      cd = "builtin cd $argv && eza -l --no-time";
      fish_greeting = "";
      fish_right_prompt = "date '+%H:%M:%S'";
      in_nix = "if set -q IN_NIX_SHELL; printf '[%s%s%s]' ; end";
      fish_prompt = ''
        				if set -q IN_NIX_SHELL
        					printf '[%s@%s%s%s] [%snix-shell%s]%s %s%s%s\n> ' $USER (set_color red) (prompt_hostname) (set_color normal) (set_color red) (set_color normal) (fish_git_prompt) (set_color green) (prompt_pwd) (set_color normal)
        				else	
        					printf '[%s@%s%s%s]%s %s%s%s\n> ' $USER (set_color red) (prompt_hostname) (set_color normal) (fish_git_prompt) (set_color green) (prompt_pwd) (set_color normal)
        				end
        			'';
    };
  };
}
