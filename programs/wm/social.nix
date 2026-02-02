{
  ...
}:
{
  flake.modules.homeManager.social =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        discord
        element-desktop
        nextcloud-client
        spotify
        telegram-desktop
      ];
    };
}
