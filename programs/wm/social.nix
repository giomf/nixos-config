{
  ...
}:
{
  flake.modules.homeManager.social =
    { pkgs, ... }:
    {
      # Turn off "Launch on system startup" in Nextcloud, or its own autostart entry starts it a second time
      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };

      home.packages = with pkgs; [
        discord
        element-desktop
        spotify
        telegram-desktop
      ];
    };
}
