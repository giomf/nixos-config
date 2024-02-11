{ pkgs, ... }:

{

  home.packages = with pkgs; [
    # nix
    nil
    nixfmt
    # bash
    nodePackages_latest.bash-language-server
    # python
    python311Packages.python-lsp-server
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
        rulers = [ 120 ];
        mouse = false;
        color-modes = true;
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        statusline = {
          left = [ "mode" "spacer" "spinner" "spacer" "version-control" ];
          center = [ "file-base-name" "file-modification-indicator" "diagnostics" ];
          right = [ "selections" "position" "total-line-numbers" ];
        };
        lsp = { display-messages = true; };
      };

      keys = {
        normal = {
          A-j = [ "extend_to_line_bounds" "delete_selection" "move_line_down" "paste_before" ];
          A-k = [ "extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before" ];
          C-j = [ "extend_to_line_bounds" "yank" "move_line_down" "paste_before" ];
          C-k = [ "extend_to_line_bounds" "yank" "move_line_up" "paste_after" ];
          D = "delete_char_backward";
          e = "move_next_word_end";
          H = "goto_line_start";
          J = [ "move_visual_line_down" "move_visual_line_down" "move_visual_line_down" ];
          K = [ "move_visual_line_up" "move_visual_line_up" "move_visual_line_up" ];
          L = "goto_line_end";
          w = "move_prev_word_start";
          W = "move_prev_long_word_start";
          X = "extend_line_above";
        };
        insert = {
          j = { k = "normal_mode"; };
        };
      };
    };
    languages = {
      language = [{
        name = "nix";
        formatter = {
          command = "nixfmt";
          args = [ "-" "-w" "120" "-q" ];
        };
      }];
    };
  };
}
