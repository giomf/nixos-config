{ ... }:

{
  flake.modules.homeManager.helix =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # nix
        nil
        nixfmt
        # bash
        nodePackages_latest.bash-language-server
        # rust
        rust-analyzer
      ];

      programs.helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          theme = "github_dark_dimmed";
          editor = {
            line-number = "relative";
            popup-border = "all";
            rulers = [ 120 ];
            mouse = false;
            color-modes = true;
            bufferline = "always";
            cursorline = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
            indent-guides = {
              render = true;
              character = "┊"; # Some characters that work well: "▏", "┆", "┊", "⸽"
              skip-levels = 1;
            };
            end-of-line-diagnostics = "hint";
            inline-diagnostics = {
              cursor-line = "warning";
              other-lines = "disable";
            };
            statusline = {
              left = [
                "mode"
                "spacer"
                "spinner"
                "spacer"
                "file-name"
                "read-only-indicator"
              ];
              center = [ "diagnostics" ];
              right = [
                "selections"
                "position"
                "position-percentage"
                "total-line-numbers"
              ];
            };
            whitespace.render = "all";
            lsp = {
              display-messages = true;
            };
            jump-label-alphabet = "asdfghjklqwertzuio";
          };

          keys = {
            normal = {
              space.g = [
                ":write-all"
                ":new"
                ":insert-output lazygit"
                ":buffer-close!"
                ":redraw"
                ":reload-all"
              ];
              C-S-j = [
                "extend_to_line_bounds"
                "delete_selection"
                "move_line_down"
                "paste_before"
              ];
              C-S-k = [
                "extend_to_line_bounds"
                "delete_selection"
                "move_line_up"
                "paste_before"
              ];
              C-j = [
                "extend_to_line_bounds"
                "yank"
                "move_line_down"
                "paste_before"
              ];
              C-k = [
                "extend_to_line_bounds"
                "yank"
                "move_line_up"
                "paste_after"
              ];
              D = "delete_char_backward";
              e = "move_next_word_end";
              H = "goto_line_start";
              J = [
                "move_visual_line_down"
                "move_visual_line_down"
                "move_visual_line_down"
              ];
              K = [
                "move_visual_line_up"
                "move_visual_line_up"
                "move_visual_line_up"
              ];
              L = "goto_line_end";
              W = "move_prev_long_word_start";
              w = "move_prev_word_start";
              X = "extend_line_above";
              space.q = ":q";
              space.w = ":w";
              C-h = "goto_previous_buffer";
              C-l = "goto_next_buffer";
              ret = "goto_word";
            };

            insert = {
              down = "no_op";
              end = "no_op";
              home = "no_op";
              j = {
                k = "normal_mode";
              };
              left = "no_op";
              pagedown = "no_op";
              pageup = "no_op";
              right = "no_op";
              up = "no_op";
            };
            select = {
              e = "move_next_word_end";
              H = "goto_line_start";
              L = "goto_line_end";
              W = "move_prev_long_word_start";
              w = "move_prev_word_start";
            };
          };
        };
        languages = {
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter = {
                command = "nixfmt";
                # args = [ "-" "-w" "120" "-q" ];
              };
            }
            {
              name = "python";
              formatter = {
                command = "bash";
                args = [
                  "-c"
                  "ruff check --select I --fix - | ruff format -"
                ];
              };
              auto-format = true;
            }
            {
              name = "cpp";
              formatter = {
                command = "clang-format";
              };
              auto-format = true;
            }
          ];
        };
      };
    };
}
