{
  ...
}:
{
  flake.modules.homeManager.terminal =
    { ... }:
    {
      programs.rio = {
        enable = true;
        # From github.com/raphamorim/rio-terminal-themes "Tomorrow Night.toml"
        themes.tomorrow-night.colors = {
          background = "#1d1f21";
          foreground = "#c5c8c6";
          selection-background = "#373b41";
          selection-foreground = "#c5c8c6";
          cursor = "#c5c8c6";
          black = "#000000";
          red = "#cc6666";
          green = "#b5bd68";
          yellow = "#f0c674";
          blue = "#81a2be";
          magenta = "#b294bb";
          cyan = "#8abeb7";
          white = "#ffffff";
          # Upstream file has #000000, which hides fish autosuggestions; Tomorrow's comment grey instead
          light_black = "#969896";
          light_red = "#cc6666";
          light_green = "#b5bd68";
          light_yellow = "#f0c674";
          light_blue = "#81a2be";
          light_magenta = "#b294bb";
          light_cyan = "#8abeb7";
          light_white = "#ffffff";
        };
        settings = {
          theme = "tomorrow-night";
          cursor = {
            shape = "beam";
            blinking = true;
          };
          # Family left at rio's bundled Cascadia Code Nerd Font (has bold/italic and icons)
          fonts.size = 15;
          # No tab bar on top; zellij handles tabs
          navigation.mode = "Plain";
          # Unbind the split keys (Linux defaults); rio only parses "control", not "ctrl"
          bindings.keys = [
            {
              key = "r";
              "with" = "control | shift";
              action = "None";
            }
            {
              key = "d";
              "with" = "control | shift";
              action = "None";
            }
          ];
        };
      };
    };
}
