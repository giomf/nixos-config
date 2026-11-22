{ ... }:
{
  # Part of the cli module, so hosts need no extra import
  flake.modules.homeManager.cli = {
    programs.yazi = {
      enable = true;
      # fish.nix defines its own `y` wrapper
      enableFishIntegration = false;
      # Same name as the fish wrapper in other shells
      shellWrapperName = "y";
      keymap.mgr.prepend_keymap = [
        {
          on = "!";
          run = ''shell "$SHELL" --block'';
          desc = "Open shell here";
        }
      ];
    };
  };
}
