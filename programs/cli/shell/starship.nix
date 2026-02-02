{ ... }:

{
  flake.modules.homeManager.shell =
    { lib, ... }:
    {
      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          add_newline = false;
          format = lib.concatStrings [
            "\\[$username@$hostname\\] "
            "$directory"
            "$git_branch"
            "$git_status"
            "$fill"
            "$cmd_duration $time"
            "$line_break"
            "$character"
            "$nix_shell"
          ];
          directory.truncate_to_repo = false;
          hostname = {
            format = "[$hostname]($style)";
            style = "bold red";
            ssh_only = false;
          };
          username = {
            show_always = true;
            format = "[$user]($style)";
            style_user = "";
            style_root = "yellow";

          };
          nix_shell = {
            format = "[$symbol]($style) ";
            symbol = "";
          };
          git_branch = {
            format = "[$symbol$branch(:$remote_branch)]($style)";
          };
          git_status = {
            format = "\\[$ahead_behind$modified$untracked$deleted$stashed$staged$renamed\\]";
            ahead = "[($count)](green)";
            behind = "[($count)](red)";
            deleted = "[✘($count)](red)";
            diverged = "[($ahead_count)($beind_count)](yellow)";
            modified = "[⌁($count)](yellow)";
            renamed = "[($count)](yellow)";
            stashed = "[⚑($count)](blue)";
            untracked = "?($count)";
            up_to_date = "[](green)";
            staged = "[+($count)](green)";

          };
          fill.symbol = " ";
          time = {
            disabled = false;
            format = "$time";
          };
          cmd_duration.format = "[$duration]($style) |";
          character = {
            success_symbol = "[](bold green)";
            error_symbol = "[](bold red)";
          };

        };
      };
    };
}
