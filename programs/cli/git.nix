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
        signing.format = null;
        settings = {
          core.excludesfile = "~/.global_gitignore";
          push.autoSetupRemote = true;
          diff = {
            colorMoved = "default";
          };
          merge = {
            conflictstyle = "diff3";
          };
          url = {
            "git@github.com:" = {
              insteadOf = "https://github.com/";
            };
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
