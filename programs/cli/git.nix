{ ... }:

{
  flake.modules.homeManager.git = {
    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          features = "mantis-shrimp-lite";
          side-by-side = true;
          line-numbers = true;
        };
      };

      git = {
        enable = true;
        settings = {
          core.excludesfile = "~/.global_gitignore";
          push.autoSetupRemote = true;
          pager.diff = "diffnav";
          diff = {
            colorMoved = "default";
          };
          merge = {
            conflictstyle = "diff3";
          };
          include = {
            path = (
              builtins.fetchurl {
                url = "https://raw.githubusercontent.com/dandavison/delta/refs/tags/0.18.2/themes.gitconfig";
                sha256 = "sha256:15f7cyf7k03dqwyfviwzxvyskrc4gdi4vn7ga21qz6fgnb7w6vzc";
              }
            );
          };
        };
      };

      lazygit = {
        enable = true;
        settings = {
          git.pagers = [
            {
              colorArgs = "always";
              pager = "delta --dark --paging=never --features mantis-shrimp-lite";
            }
          ];
        };
      };
    };
  };
}
