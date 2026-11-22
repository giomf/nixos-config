{
  ...
}:
{
  flake.modules.homeManager.terminal =
    { lib, config, ... }:
    {
      programs.rio = {
        enable = true;
        settings = {
          # Stylix maps this to base02, too dark for fish autosuggestions; use the comment grey (base03) instead
          colors.light-black = lib.mkForce config.lib.stylix.colors.withHashtag.base03;
          cursor = {
            shape = "beam";
            blinking = true;
          };
          # Colors, font family and size come from stylix; rio only scans /usr/share/fonts and ~/.fonts
          fonts.additional-dirs = [ "/run/current-system/sw/share/X11/fonts" ];
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
